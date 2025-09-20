# examples/count_calls.jl
# Purpose: Demonstrates the use of function and gradient call counters, including resetting, for a test function.
# Context: Part of NonlinearOptimizationTestFunctions, showcasing the tracking of f and gradient! calls.
# Last modified: 11 September 2025

# Helper function: Main execution logic for the example
# Purpose: Evaluates the Rosenbrock function, its gradient, performs optimization, and displays call counts.
# Input: None
# Output: None (prints results to console)
# Used in: This file, executed directly or via runallexamples.jl

using NonlinearOptimizationTestFunctions
using Optim

function run_count_calls_example()
    

    # Select the Rosenbrock test function
    tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
    n = 2  # Dimension for scalable function

    # Reset counters before starting
    reset_counts!(tf)  # Reset function and gradient call counters to 0
    println("After reset - Function calls: ", get_f_count(tf))  # Should print 0
    println("After reset - Gradient calls: ", get_grad_count(tf))  # Should print 0

    # Evaluate function at start point
    x = tf.meta[:start](n)  # Get start point [1.0, 1.0]
    f_value = tf.f(x)  # Compute function value
    println("Function value at start point $x: ", f_value)  # Should print 24.0
    println("Function calls after evaluation: ", get_f_count(tf))  # Should print 1

    # Evaluate gradient at start point
    grad_value = tf.grad(x)  # Compute gradient
    println("Gradient at start point $x: ", grad_value)  # Should print [400.0, -200.0]
    println("Gradient calls after evaluation: ", get_grad_count(tf))  # Should print 1

    # Perform optimization with L-BFGS
    result = optimize(tf.f, tf.gradient!, x, LBFGS(), Optim.Options(f_reltol=1e-6))
    println("Optimization result - Minimizer: ", Optim.minimizer(result))
    println("Optimization result - Minimum: ", Optim.minimum(result))
    println("Function calls after optimization: ", get_f_count(tf))  # Prints total function calls
    println("Gradient calls after optimization: ", get_grad_count(tf))  # Prints total gradient calls

    # Reset counters again
    reset_counts!(tf)  # Reset counters to 0
    println("After second reset - Function calls: ", get_f_count(tf))  # Should print 0
    println("After second reset - Gradient calls: ", get_grad_count(tf))  # Should print 0
end #function

# Execute the example
# Purpose: Runs the demonstration when the file is included or executed.
# Context: Ensures the example runs standalone or via runallexamples.jl.
run_count_calls_example()