# Box Constraints Handling in NonlinearOptimizationTestFunctions.jl

## Overview

Many benchmark functions in this package are **bounded** (i.e., defined only within specific lower and upper bounds `lb` and `ub`).  
These bounds frequently define the **valid domain** of the function or its gradient (e.g., to avoid undefined operations like logarithms of negative values or division by zero).

To enable the use of **unconstrained** optimizers (e.g., LBFGS, BFGS, ConjugateGradient, GradientDescent, Newton, etc.) on these problems, the package provides a robust wrapper:

```julia
tf_unconstrained = with_box_constraints(tf)
```

This wrapper implements a **domain-safe modified exact L1 penalty** approach specifically tailored for benchmark functions.

## How the Wrapper Works

The wrapper ensures **safe evaluation** while maintaining the benefits of an exact penalty method:

- Before evaluating the original objective `f(x)` or its gradient, the point `x` is **clamped/projected** to the feasible region:  
  ```julia
  x_clamped = max.(lb, min.(x, ub))
  ```
- The original function and analytical gradient are **always evaluated only inside the valid bounds** (domain-safe evaluation).
- An **L1 penalty term** with a large fixed parameter ρ = 10⁶ is added to discourage the optimizer from remaining unnecessarily at the boundary:  
  \[
  \tilde{f}(+x) = f(x_{\text{clamped}}) + \rho \sum_i \left( \max(0, l_i - x_i) + \max(0, x_i - u_i) \right)
  \]
- The gradient is correctly adjusted using subgradients at the boundaries.

This hybrid strategy combines the **exactness** of L1 penalties with the **safety** of projection, making it far more robust than pure penalty methods or projection-based approaches on functions with domain-restricted definitions.

**Key advantage**: The wrapper works with **any unconstrained optimization method** available in Optim.jl, GalacticOptim.jl, or custom implementations — you are not restricted to a specific algorithm.

## Comparison with Optim.jl's Fminbox

Optim.jl provides `Fminbox`, a built-in box-constrained optimizer that combines an unconstrained method with gradient projection and resetting at bounds.  
**Limitation**: `Fminbox` currently only supports **LBFGS** as the inner solver.

A comprehensive benchmark (`examples/benchmark_box_constraints.jl`, December 2025) compares:

- `Fminbox` + LBFGS (standard linesearch)
- `with_box_constraints` + LBFGS with **BackTracking** linesearch

**Benchmark results** (155 bounded functions, 10 random strictly feasible starts each):
- **Robustness** (higher success rate):
  - L1 wrapper more robust: **~120 functions**
  - Fminbox more robust: **~15 functions**
  - Equal robustness (>0% success): **~20 functions**
- The wrapper frequently converges where `Fminbox` fails (e.g., due to NaN in projected gradients on functions like `bartelsconn`, `rump`, `alpinen1`, `bukin*`).
- When both converge, the wrapper is typically **faster** (fewer total function + gradient calls).

Overall, the wrapper is **more robust**, often **more efficient**, and **significantly more flexible** (any optimizer) than `Fminbox`.

## Usage Example

```julia
using NonlinearOptimizationTestFunctions
using Optim
using LineSearches  # recommended for the wrapper

# Select a bounded test function
tf_orig = ACKLEY_FUNCTION
tf = fixed(tf_orig; n = 10)  # fix dimension if scalable

# Apply the domain-safe wrapper
tf_unconstrained = with_box_constraints(tf)

# Use any unconstrained optimizer (LBFGS with BackTracking recommended)
optimizer = LBFGS(linesearch = BackTracking())

# Strictly feasible random start point (recommended)
lower = Float64.(lb(tf))
upper = Float64.(ub(tf))
x0 = lower + (upper - lower) .* rand(length(lower))
x0 = clamp.(x0, lower + 1e-8, upper - 1e-8)  # ensure strict feasibility

# Optimize
result = optimize(tf_unconstrained.f, tf_unconstrained.gradient!,
                  x0, optimizer,
                  Optim.Options(f_reltol = 1e-8, iterations = 20_000))

println("Converged: ", Optim.converged(result))
println("Minimizer: ", Optim.minimizer(result))
println("Minimum:   ", Optim.minimum(result))
```

## Recommendations

- Use `with_box_constraints` for **maximum robustness and flexibility**, especially on functions where bounds define the valid domain.
- Pair it with `LBFGS(linesearch = BackTracking())` or `BackTracking(order=3)` for best handling of the non-smooth penalty.
- Use `Fminbox` only if you specifically need its projection behavior and accept the limitation to LBFGS.

The wrapper makes the entire collection of bounded test functions safely usable with **any** unconstrained optimizer while delivering excellent practical performance.

# Appendix: Advantages and Differences to Traditional L1 Wrappers

This appendix compares the package's `with_box_constraints` wrapper to traditional exact L1 penalty methods, highlighting its domain-safe design and practical benefits.

## Traditional Exact L1 Penalty Methods

In classical exact L1 penalty approaches (e.g., as described in optimization literature), a constrained problem \(\min f(x)\) s.t. \(l \leq x \leq u\) is transformed into an unconstrained one:

\[
\tilde{f}(x) = f(x) + \rho \sum_i \left( \max(0, l_i - x_i) + \max(0, x_i - u_i) \right)
\]

- Evaluations of \(f(x)\) and \(\nabla f(x)\) occur **directly at the unbound \(x\)**, even if outside bounds.
- For sufficiently large fixed \(\rho > \rho^*\) (threshold based on Lagrange multipliers), local minima coincide exactly.
- Gradient: \(\nabla \tilde{f}(x) = \nabla f(x) + \rho \sum_i \partial v_i(x)\), where \(v_i(x)\) is the bound violation (subgradient at kinks).

This works well for functions defined everywhere but can fail if \(f\) or \(\nabla f\) is undefined/unstable outside bounds (e.g., domain errors like \(\log(x)\) for \(x < 0\)).

## The Package's Domain-Safe L1 Penalty Wrapper

The `with_box_constraints` implements a **modified exact L1 penalty** with pre-clamping:

- Compute \(x_{\text{clamped}} = \max(l, \min(x, u))\).
- Penalized objective:  
  \[
  \tilde{f}(x) = f(x_{\text{clamped}}) + \rho \sum_i v_i(x)
  \]
  (fixed \(\rho = 10^6\)).
- Gradient: \(\nabla \tilde{f}(x) = \nabla f(x_{\text{clamped}}) + \rho \sum_i \partial v_i(x)\) (subgradient-adjusted).

- \(f\) and \(\nabla f\) are **always evaluated inside the valid domain** (at \(x_{\text{clamped}}\)).
- The penalty on unbound \(x\) ensures the gradient "pulls inward" for violations.

## Key Differences

- **Evaluation Point**: Traditional methods evaluate at unbound \(x\) (risking domain errors). The wrapper clamps first, ensuring domain-safety.
- **Handling Violations**: Both penalize violations, but the wrapper's clamping prevents unstable evaluations while the penalty corrects the direction.
- **Exactness**: Both are exact for large \(\rho\), but the wrapper's hybrid (clamp + penalty) adds safety without losing theoretical guarantees (as long as \(\rho\) dominates the clamped gradient).
- **Smoothness**: Both are non-smooth (kinks from max/abs), but the wrapper's clamping can make the effective landscape "smoother" near bounds by avoiding explosions in \(f\).
- **Flexibility**: The wrapper supports any unconstrained optimizer; traditional penalties do too, but without domain-safety, they may crash on benchmark functions.

## Advantages of the Domain-Safe Wrapper

1. **Domain Safety**: Always evaluates within bounds, preventing NaN, Inf, or DomainErrors—critical for benchmarks with hard domains (e.g., logs, roots).
2. **Guaranteed Inward Pull**: The penalty dominates violations, ensuring the gradient pulls components "inward" without being overpowered by unstable external gradients (as in traditional methods).
3. **Robustness**: As shown in benchmarks, higher success rates on ill-conditioned or non-differentiable functions where traditional penalties or projections (e.g., Fminbox) fail.
4. **Efficiency**: Fewer calls in practice (avoids wasted evaluations outside domain) and better numerical stability.
5. **Ease of Use**: Seamless for any gradient-based unconstrained solver, with no need for custom projections.

This design makes the wrapper particularly suited for test function libraries, where bounds often define validity rather than just constraints.