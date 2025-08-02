# examples/Optimize_all_functions.jl
# Purpose: Optimizes all test functions using Optim.jl's L-BFGS algorithm.
# Context: Part of NonlinearOptimizationTestFunctions, showcasing TestFunction integration.
# Last modified: 11. Juli 2025, 14:10 PM CEST
using NonlinearOptimizationTestFunctions, Optim
n = 2
for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
    println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
end