# examples/newton_method_demo.jl
# =============================================================================
# Purpose: 
#   Demonstrates a simple, hand-written Newton's method for unconstrained 
#   minimization using the analytical gradient and a numerically computed Hessian
#   from the NonlinearOptimizationTestFunctions.jl package.
#
# Philosophical alignment with the package:
#   • Full transparency: No black-box optimizer – every step is visible and 
#     understandable.
#   • Maximum use of analytical information: Gradient is exact (from package),
#     Hessian is computed numerically via Zygote (second-order AD).
#   • Educational value: Shows how second-order methods work in practice on 
#     real benchmark problems.
#   • Highlights the package's strength: Exact gradients + rich metadata 
#     (start point, known minimum) make such experiments easy and reliable.
#
# Chosen test function: Rosenbrock in 10 dimensions (scalable → fixed)
#   • Classic ill-conditioned, non-convex "banana valley" extended to higher dimension
#   • Exact global minimum at [1.0, 1.0, ..., 1.0] with f = 0.0
#   • Perfect for demonstrating quadratic convergence of Newton's method
#     and the effect of higher dimensionality on conditioning
#
# Expected behaviour:
#   • Fast quadratic convergence near the minimum
#   • Typically < 20 iterations to high precision (even in n=10)
#   • Trajectory printed step-by-step
#
# Last modified: December 2025
# =============================================================================

using NonlinearOptimizationTestFunctions
using Zygote          # Automatic Hessian via second-order AD
using LinearAlgebra
using Printf          # Formatted output

# -------------------------------------------------------------------------
# Select the scalable Rosenbrock function and convert to fixed n=10
# -------------------------------------------------------------------------
tf_orig = TEST_FUNCTIONS["rosenbrock"]   # or ROSENBROCK_FUNCTION

# Convert to fixed 10-dimensional instance – this binds all metadata (start, min_position, etc.)
tf = fixed(tf_orig; n=10)

println("Newton's method demo on: $(tf.name) (n = $(dim(tf)))")
println("Global minimum: $(min_value(tf)) at ones($(dim(tf)))")
println("Note: Scalable function converted to fixed n=10 via fixed() for this demo.\n")

# -------------------------------------------------------------------------
# Starting point – use the package's recommended (challenging) start for n=10
# -------------------------------------------------------------------------
x = Float64.(start(tf))
println("Starting point: $x")
println("Initial objective: $(tf.f(x))")
println()

# -------------------------------------------------------------------------
# Newton's method parameters
# -------------------------------------------------------------------------
max_iter = 100
tol = 1e-10          # Gradient norm tolerance (slightly relaxed for higher dim)

println("Running Newton's method (max $max_iter iterations, ‖∇f‖ < $tol):\n")
@printf("%-4s %-30s %-18s %-15s\n", "Iter", "‖x - x*‖ (approx)", "f(x)", "‖∇f(x)‖")

true_minimum = ones(dim(tf))

for iter in 1:max_iter
    f_val = tf.f(x)
    grad = tf.grad(x)
    norm_grad = norm(grad)
    dist_to_min = norm(x - true_minimum)

    @printf("%-4d %-30.10e %-18.10e %-15.10e\n", iter - 1, dist_to_min, f_val, norm_grad)

    if norm_grad < tol
        println("\nConverged after $iter iterations!")
        break
    end

    # Compute Hessian via Zygote (automatic second-order differentiation)
    H = Zygote.hessian(tf.f, x)

    # Safeguard: If Hessian not positive definite, fall back to steepest descent
    if !isposdef(H)
        println("    Warning: Hessian not positive definite – using steepest descent step")
        direction = -grad
    else
        direction = -H \ grad
    end

    # Pure Newton step (step size = 1.0)
    # Works well due to quadratic convergence near the minimum
    global x = x + direction  # Explicit 'global x' to update the outer variable
end

# -------------------------------------------------------------------------
# Final result
# -------------------------------------------------------------------------
final_f = tf.f(x)
final_pos = x
final_grad_norm = norm(tf.grad(x))
final_dist = norm(x - true_minimum)

println("\n=== Final result ===")
println("Final point            : $final_pos")
println("Final objective        : $final_f")
println("‖∇f‖ at end            : $final_grad_norm")
println("Distance to true min   : $final_dist")

if final_f < 1e-12 && final_grad_norm < 1e-8
    println("\n→ Successfully reached near-global minimum with high precision!")
else
    println("\n→ Converged well, but higher dimension increases conditioning challenges.")
end

# =============================================================================
# Why this example embodies the package's philosophy
# =============================================================================
# • Transparency: Full view of every Newton step – no hidden magic.
# • Educational: Directly illustrates quadratic convergence and the role of the Hessian.
# • Leverages package features:
#     - Exact analytical gradients
#     - Scalable functions → easy conversion to higher dimensions via fixed()
#     - Known true minimum for immediate validation
#     - Challenging start point from metadata
# • Demonstrates real-world behaviour: Newton's method shines near the solution
#   but requires good conditioning – Rosenbrock in higher dimensions shows this clearly.
#
# Try changing n in fixed(tf_orig; n=...) to 2, 20, or 50 to see how dimension
# affects convergence speed and numerical stability.
#
# This kind of hands-on experiment is only possible because the package provides
# rigorously verified analytical derivatives and comprehensive metadata.
# =============================================================================