# examples/Compare_optimization_methods.jl
# Purpose: Compares Gradient Descent and L-BFGS on the Rosenbrock function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, showing flexibility of TestFunction.
# Last modified: 11. Juli 2025, 14:10 PM CEST
using NonlinearOptimizationTestFunctionsInJulia, Optim
tf = NonlinearOptimizationTestFunctionsInJulia.ROSENBROCK_FUNCTION
n = 2
result_gd = optimize(tf.f, tf.gradient!, tf.meta[:start](n), GradientDescent(), Optim.Options(f_reltol=1e-6))
result_lbfgs = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
println("Gradient Descent on $(tf.meta[:name]): $(Optim.minimizer(result_gd)), $(Optim.minimum(result_gd))")
println("L-BFGS on $(tf.meta[:name]): $(Optim.minimizer(result_lbfgs)), $(Optim.minimum(result_lbfgs))")