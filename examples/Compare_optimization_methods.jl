# examples/Compare_optimization_methods.jl
# Purpose: Compares Gradient Descent and L-BFGS optimization methods on the Rosenbrock function.
# Context: Part of NonlinearOptimizationTestFunctions, demonstrating the flexibility of the TestFunction interface.
# Last modified: 18 September 2025, 11:15 AM CEST

using NonlinearOptimizationTestFunctions, Optim

# Load the Rosenbrock function
tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION

# Set the number of dimensions (default for Rosenbrock is n=2)
n = 2

# Perform optimization using Gradient Descent
result_gd = optimize(
    tf.f,              # Objective function
    tf.gradient!,      # Gradient function
    start(tf),      # Starting point
    GradientDescent(), # Optimization algorithm
    Optim.Options(f_reltol=1e-6) # Convergence tolerance
)

# Perform optimization using L-BFGS
result_lbfgs = optimize(
    tf.f,              # Objective function
    tf.gradient!,      # Gradient function
    start(tf),      # Starting point 
    LBFGS(),           # Optimization algorithm
    Optim.Options(f_reltol=1e-6) # Convergence tolerance
)

# Print results
println("Gradient Descent on $(tf.name): minimizer = $(Optim.minimizer(result_gd)), minimum = $(Optim.minimum(result_gd))")
println("L-BFGS on $(tf.name): minimizer = $(Optim.minimizer(result_lbfgs)), minimum = $(Optim.minimum(result_lbfgs))")