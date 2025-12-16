# testing.md

# Testing in NonlinearOptimizationTestFunctions.jl

The package includes a comprehensive test suite to ensure correctness, consistency, and robustness of all benchmark functions. Tests are located in the `test/` directory and are executed via `test/runtests.jl`.

The suite consists of cross-function tests (applied to all functions) and function-specific tests (one file per function).

## Cross-Function Tests (in `test/runtests.jl`)

These tests run on every registered function and enforce package-wide invariants.

| Test Set                                | Description                                                                 | Key Checks |
|-----------------------------------------|-----------------------------------------------------------------------------|------------|
| Property Consistency Checks             | Verifies logical implications and mutual exclusions between properties.     | e.g., convex cannot coexist with multimodal or non-convex; differentiable excludes has_noise. |
| Minimum Validation                      | Checks that the reported global minimum value is attained at the reported position. | Tolerance 1e-6; range check for noisy functions. |
| Edge Cases                              | Tests behaviour at extreme inputs (empty vector, NaN, Inf, very small values, bounds). | Throws on empty input; returns NaN/Inf correctly; checks finiteness at bounds or infinity. |
| Zygote Hessian                          | Limited test on selected smooth functions: computes Hessian via Zygote and checks size/finiteness. | Currently on Rosenbrock, Sphere, AxisParallelHyperellipsoid (n=2). |
| Start Point Tests                       | For bounded differentiable functions: ensures start point is not the global minimum. | Avoids trivial convergence in 0 iterations. |
| Start Point Feasibility (within bounds) | For bounded functions: start point must be within bounds; warns if exactly on boundary. | Fails if outside bounds; warns if on boundary (compatibility with strict interior-point solvers). |

## Function-Specific Tests

### Global Minimum Validation (in `test/minima_tests.jl`)

A dedicated test suite that runs on all functions using Nelder-Mead optimization to validate the reported global minimum.

- Uses derivative-free Nelder-Mead for broad applicability (including multimodal and noisy cases).
- Handles scalable functions by testing multiple dimensions if needed.
- Special handling for noisy functions (multiple evaluations, range checks).
- If Nelder-Mead finds a better point, it prints suggested metadata updates with high precision.
- Provides detailed warnings and improvement suggestions for failing cases.

### Individual Function Tests (in `test/<name>_tests.jl`)

Each function has its own test file (included via `test/include_testfiles.jl`). These contain function-specific checks such as:

- Name and property assertions
- Minimum achievement verification
- Gradient accuracy (comparison with ForwardDiff where applicable)
- Start point quality (not the minimum, within bounds)
- Edge case handling
- Optional high-precision validation with BigFloat

## Running the Tests

julia> using Pkg
julia> Pkg.test("NonlinearOptimizationTestFunctions")

All tests are expected to pass on a clean installation.

## Development Guidelines for New Functions (Testing Perspective)

The package includes a detailed guide for adding new test functions (see `docs/contributing_new_function.md` or the development section in README).

Key testing-related rules from the guide:

- Every new function **must** have a corresponding test file `test/<name>_tests.jl`.
- Metadata must satisfy all consistency rules (validated by cross-function tests).
- Start point must be within bounds (strict interior preferred) and not the minimum.
- Analytical gradient must be verified (preferably with high-precision checks).
- Properties must be sourced from literature and consistent with the implemented formula.

These rules are enforced by the test suite – a new function will fail tests if they are violated.

## Design Philosophy

- Strict consistency enforcement through property checks.
- Robust minimum validation using derivative-free optimization.
- Comprehensive coverage with cross-function and per-function tests.
- Self-documenting failures with concrete fix suggestions.

Contributions adding new functions must include corresponding tests and pass the full suite.

For questions about testing or to report issues, open an issue on the repository.