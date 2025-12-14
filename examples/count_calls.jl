# examples/count_calls.jl
# =============================================================================
# Purpose: 
#   This example demonstrates the built-in call counting and resetting functionality
#   of TestFunction objects in NonlinearOptimizationTestFunctions.jl.
#
# Why this feature exists:
#   • When benchmarking optimizers or comparing algorithms, it is crucial to know
#     exactly how many objective function evaluations (f-count) and gradient evaluations
#     (grad-count) were performed.
#   • The package automatically wraps every TestFunction's f and grad with counters
#     (Ref{Int}) that increment on each call – completely transparent to the user.
#   • reset_counts!(tf) allows starting fresh for each experiment.
#   • This makes fair, reproducible comparisons possible without modifying the optimizer.
#
# Key functions demonstrated:
#   • get_f_count(tf)     → number of objective evaluations
#   • get_grad_count(tf)  → number of gradient evaluations
#   • reset_counts!(tf)   → set both counters back to zero
#
# Expected behaviour:
#   • Counters start at 0 after reset
#   • Each tf.f(x) increments f-count by 1
#   • Each tf.grad(x) or tf.gradient!(g,x) increments grad-count by 1
#   • Optimization with Optim.jl (L-BFGS) shows realistic call numbers
#   • Second reset brings counters back to 0
#
# Last modified: December 2025
# =============================================================================

using NonlinearOptimizationTestFunctions
# Core package – every TestFunction automatically tracks f and gradient calls.

using Optim
# Standard optimization library used here to show real-world usage of the counters.

# -------------------------------------------------------------------------
# Main demonstration function
# -------------------------------------------------------------------------
function run_count_calls_example()
    # Select the classic Rosenbrock function (scalable, but we use n=2 here)
    # f(x) = ∑ [100*(x_{i+1} - x_i²)² + (1 - x_i)²]   → global minimum 0 at x = [1,1,...,1]
    tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
    n = 2  # Fixed dimension for this demonstration

    # ---------------------------------------------------------------------
    # Start with clean counters
    # ---------------------------------------------------------------------
    reset_counts!(tf)  # Zero both internal Ref{Int} counters
    println("After reset - Function calls: ", get_f_count(tf))   # → 0
    println("After reset - Gradient calls: ", get_grad_count(tf)) # → 0
    println()

    # ---------------------------------------------------------------------
    # Manual function and gradient evaluation
    # ---------------------------------------------------------------------
    x = tf.meta[:start](n)  # Recommended starting point from metadata (usually far from minimum)
    # For Rosenbrock n=2: typically [ -1.2, 1.0 ] or similar – deliberately challenging

    f_value = tf.f(x)       # One objective evaluation
    println("Function value at start point $x: ", f_value)
    println("Function calls after f(x): ", get_f_count(tf))      # → 1

    grad_value = tf.grad(x) # One gradient evaluation (out-of-place version)
    println("Gradient at start point $x: ", grad_value)
    println("Gradient calls after grad(x): ", get_grad_count(tf)) # → 1
    println()

    # ---------------------------------------------------------------------
    # Run an actual optimization and observe how many calls are made
    # ---------------------------------------------------------------------
    # Optim.jl's L-BFGS will repeatedly call tf.f and tf.gradient! during line search
    # and model building – the counters will accumulate all of these calls.
    result = Optim.optimize(
        tf.f,              # objective
        tf.gradient!,      # in-place gradient (preferred for performance)
        x,                 # initial guess
        Optim.LBFGS(),     # limited-memory quasi-Newton method
        Optim.Options(f_reltol=1e-6)  # stop when relative function change < 1e-6
    )

    println("Optimization result - Minimizer: ", Optim.minimizer(result))
    println("Optimization result - Minimum:   ", Optim.minimum(result))
    # Typical numbers for Rosenbrock n=2 with L-BFGS:
    #   ~20–40 function calls
    #   ~20–40 gradient calls
    # Exact numbers may vary slightly depending on Julia/Optim version and tolerances.
    println("Function calls after optimization: ", get_f_count(tf))
    println("Gradient calls after optimization: ", get_grad_count(tf))
    println()

    # ---------------------------------------------------------------------
    # Reset counters again – ready for the next experiment
    # ---------------------------------------------------------------------
    reset_counts!(tf)
    println("After second reset - Function calls: ", get_f_count(tf))   # → 0
    println("After second reset - Gradient calls: ", get_grad_count(tf)) # → 0
end

# -------------------------------------------------------------------------
# Execute the example when the file is loaded
# -------------------------------------------------------------------------
# This ensures the demonstration runs automatically whether the file is
#   • run directly (julia count_calls.jl)
#   • included from runallexamples.jl
#   • loaded interactively
run_count_calls_example()

