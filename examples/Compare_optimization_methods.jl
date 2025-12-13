# examples/Compare_optimization_methods.jl
# Purpose: Compares Gradient Descent and L-BFGS optimization methods on the Rosenbrock function.
# Context: Part of NonlinearOptimizationTestFunctions, demonstrating the flexibility of the TestFunction interface.
# Last modified: 18 September 2025, 11:15 AM CEST

using NonlinearOptimizationTestFunctions, Optim

# Load the original Rosenbrock function
tf_orig = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION

# Set the number of dimensions
n = 2

# FIX: Convert the scalable function into a fixed function (with dimension n).
# This removes the "scalable" property, allowing start(tf) to work without n.
tf = fixed(tf_orig, n)

# Perform optimization using Gradient Descent
result_gd = Optim.optimize(
    tf.f,              # Objective function
    tf.gradient!,      # Gradient function
    start(tf),         # Starting point can now be retrieved without n
    GradientDescent(), # Optimization algorithm
    Optim.Options(f_reltol=1e-6) # Convergence tolerance
)

# Perform optimization using L-BFGS
result_lbfgs = Optim.optimize(
    tf.f,              # Objective function
    tf.gradient!,      # Gradient function
    start(tf),         # Starting point can now be retrieved without n
    LBFGS(),           # Optimization algorithm
    Optim.Options(f_reltol=1e-6) # Convergence tolerance
)

# Print results
println("Gradient Descent on $(tf.name): minimizer = $(Optim.minimizer(result_gd)), minimum = $(Optim.minimum(result_gd))")
println("L-BFGS on $(tf.name): minimizer = $(Optim.minimizer(result_lbfgs)), minimum = $(Optim.minimum(result_lbfgs))")