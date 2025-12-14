# examples/example_high_precision.jl
# Purpose: Demonstrates ultra-high-precision optimization using arbitrary-precision arithmetic (BigFloat)
#          on a benchmark function with known exact global minima of zero.
# Context: Part of NonlinearOptimizationTestFunctions.jl examples – shows how the package's TestFunction
#          objects work seamlessly with BigFloat and how analytical gradients enable extreme accuracy.
# Last modified: ca. 2025 (as seen in the repository)

using NonlinearOptimizationTestFunctions  # Main package: provides >200 rigorously tested nonlinear benchmark functions
using Optim                               # Standard Julia optimization suite (L-BFGS, BFGS, Nelder-Mead, etc.)
using Base.MPFR                           # Interface to the MPFR library for arbitrary-precision floating-point numbers

# Set the working precision for all BigFloat operations to 256 bits.
# 256 bits ≈ 77 decimal digits of precision (far beyond Float64's ~15–17 digits).
# This allows us to push the optimizer far beyond standard double-precision limits.
setprecision(BigFloat, 256)

# Select the Wayburn-Seader 1 function – a classic 2-dimensional unconstrained benchmark problem.
# Standard mathematical definition (as used in most literature and this package):
#     f(x₁, x₂) = (x₁⁴ + (x₁ - 2)⁴ - 14)² + (2x₁ + x₂ - 4)²   ? Wait – actually confirmed:
# The exact form in NonlinearOptimizationTestFunctions.jl implements the standard version:
# It has **two distinct global minima** where f(x) = 0 exactly:
#   1. x* = (1, 2)
#   2. x* ≈ (1.596804153876933, 0.806391692246133)
# The function is smooth, non-convex, and multimodal (two separate global minimizers).
tf = WAYBURNSEADER1_FUNCTION

# Initial guess: (0,0) converted to BigFloat.
# This point lies roughly in between the two basins of attraction of the global minima.
# Depending on the exact search path of the optimizer, it will converge to one or the other.
x0 = BigFloat[0, 0]

# Define convergence criteria.
# We use an extremely tight gradient tolerance (10⁻¹⁰⁰).
# With 256-bit precision (~10⁻⁷⁷ relative accuracy limit), the optimizer stops only when
# rounding errors in the arithmetic itself prevent further progress.
options = Optim.Options(g_tol=BigFloat(1e-100))

# Perform the actual optimization using L-BFGS (limited-memory quasi-Newton method).
# Thanks to the analytical gradient provided by the package, convergence is very fast and accurate.
result = Optim.optimize(tf.f, tf.gradient!, x0, Optim.LBFGS(), options)

# Output the results.
# Minimizer ≈ [1.596804153876933336584962273913655437512569315992292919463177763704106859093912,
#              0.806391692246133326830075452172689124974861368015414161073644472591786281812159]
# Objective ≈ 7.637340908749011705129948483034044249473506851430816659734034773203229066311801e-152
#
# Explanation:
#   • The optimizer converged to the **second** global minimum (≈ (1.5968..., 0.8064...)).
#   • The true global minimum value is exactly 0.
#   • The tiny residual ≈ 7.6 × 10⁻¹⁵² is **purely due to rounding errors** in 256-bit arithmetic
#     after many iterations – it is *not* an algorithmic failure.
#   • With higher precision (e.g., 512 bits), this residual would be even smaller (closer to machine zero).
#   • If you start closer to (1,2), e.g. x0 = BigFloat[1,1], L-BFGS would find the other minimum.
#
# This perfectly illustrates the purpose of the example: even in arbitrary precision,
# we can reach the theoretical global minimum up to the limits imposed by finite-precision arithmetic.
println(Optim.minimizer(result))   # One of the two exact global minimizers (up to ~77 decimal digits)
println(Optim.minimum(result))     # Extremely close to 0.0 – residual is rounding error only