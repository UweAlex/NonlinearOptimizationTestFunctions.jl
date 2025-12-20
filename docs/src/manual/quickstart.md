# Quickstart

## Why This Package?

`NonlinearOptimizationTestFunctions.jl` stands out for serious benchmarking of nonlinear optimization algorithms:

- **Exact analytical gradients** – 10–100× faster and more accurate than finite differences
- **Over 200 rigorously verified functions** – covering classics from Jamil & Yang, BBOB, CEC, and more
- **Comprehensive metadata** – known global minima, bounds, recommended starting points, properties, and literature references
- **Zero boilerplate** – everything needed for reproducible tests is pre-defined and consistency-checked

## Installation

```julia
using Pkg
Pkg.add("NonlinearOptimizationTestFunctions")
```

## First Steps (Complete Beginner)

```julia
using NonlinearOptimizationTestFunctions

# List all available functions (by their canonical lowercase name)
all_names = sort(collect(keys(TEST_FUNCTIONS)))
println("Total functions: $(length(all_names))")

# Pick a simple fixed-dimension function (unimodal, convex)
tf = TEST_FUNCTIONS["sphere"]  # Access via the dictionary key (the official :name)

# Evaluate at the recommended (challenging) starting point
x = start(tf)                  # Vector deliberately away from the minimum
println("f(start): ", tf.f(x)) # Large positive value

# Known global minimum
println("Global minimum: ", min_value(tf), " at ", min_position(tf))  # 0.0 at zeros
```

**Note**: All functions are registered in the dictionary `TEST_FUNCTIONS` using their canonical lowercase name (exactly matching the `:name` field in metadata).  
This is the most reliable and future-proof way to access them – no need to guess uppercase constant names.

For convenience, many popular functions also export uppercase constants (e.g., `ROSENBROCK_FUNCTION`, `ACKLEY_FUNCTION`), but the dictionary lookup works for **every** function without exception.

## Core Concepts

### Fixed vs. Scalable Functions

```julia
n = dim(tf)
if n == -1
    println("Scalable function – use fixed(tf; n=...) to set a dimension")
else
    println("Fixed dimension: $n")
end
```

- **Fixed**: Direct metadata access (e.g., `start(tf)`, `min_position(tf)`)
- **Scalable**: First create a fixed instance with `fixed()`

```julia
# Classic Rosenbrock (scalable) – accessed safely via dictionary
rosen_tf = TEST_FUNCTIONS["rosenbrock"]

# Recommended: uses the package-defined :default_n for literature consistency
tf_default = fixed(rosen_tf)

# Or choose your own dimension
tf10 = fixed(rosen_tf; n=10)
```

### Essential Accessors

| Accessor                  | Purpose                                   | Example (Rosenbrock)               |
|---------------------------|-------------------------------------------|------------------------------------|
| `name(tf)`                | Canonical name                            | "rosenbrock"                       |
| `dim(tf_fixed)`           | Dimension (after fixing)                  | 10                                 |
| `properties(tf)`          | Sorted characteristics                    | ["continuous", "differentiable", ...] |
| `source(tf)`              | Literature reference                      | "Jamil & Yang (2013, p. XX)"       |
| `start(tf_fixed)`         | Challenging starting point                | e.g., [-1.2, 1.0, -1.2, ...]       |
| `min_value(tf_fixed)`     | Known global minimum value                | 0.0                                |
| `min_position(tf_fixed)`  | Position of global minimum                | ones(n)                            |
| `lb(tf_fixed)`, `ub(tf_fixed)` | Bounds (if applicable)               | vectors                            |

### Evaluating Functions and Gradients

```julia
x = start(tf10)
f_val = tf10.f(x)

# Out-of-place gradient (convenient)
grad = tf10.grad(x)

# In-place gradient (recommended for optimizers – zero allocation)
g = similar(x)
tf10.gradient!(g, x)
```

## Common Workflows

### Workflow 1: Unconstrained Optimization

```julia
using Optim

tf2 = fixed(TEST_FUNCTIONS["rosenbrock"]; n=2)
result = optimize(tf2.f, tf2.gradient!, start(tf2), LBFGS())

println("Minimizer: ", minimizer(result))  # ≈ [1.0, 1.0]
println("Minimum:   ", minimum(result))    # ≈ 0.0
```

### Workflow 2: Handling Bounds

```julia
tf_bounded = with_box_constraints(fixed(TEST_FUNCTIONS["branin"]))

result = optimize(tf_bounded.f, tf_bounded.gradient!, start(tf_bounded), LBFGS())
# Automatically respects bounds
```

### Workflow 3: Building Targeted Benchmark Suites

```julia
# Example: all multimodal functions
suite = filter_testfunctions(multimodal)

hard_suite = filter_testfunctions(tf -> multimodal(tf) && bounded(tf) && !convex(tf))

for tf_orig in hard_suite[1:10]
    tf_fixed = fixed(tf_orig)  # Use default_n where defined
    # Run your optimizer...
end
```

## Tracking Algorithm Performance

```julia
reset_counts!(tf_fixed)
result = optimize(tf_fixed.f, tf_fixed.gradient!, start(tf_fixed), LBFGS())

println("Objective calls: ", get_f_count(tf_fixed))
println("Gradient calls:  ", get_grad_count(tf_fixed))
```

## Advanced Topics

- **Arbitrary-precision arithmetic** – use `BigFloat` inputs seamlessly
- **Noisy functions** – metadata includes special validation rules

See the full manual for details.

## Next Steps

- Browse the complete function list: `docs/all_functions.md` (auto-generated)
- Explore examples in the `examples/` directory
- All functions are reliably accessible via `TEST_FUNCTIONS["name"]`
