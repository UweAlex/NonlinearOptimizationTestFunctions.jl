# examples/Optimize_with_nlopt.jl
# Purpose: Demonstrates optimization of the Rosenbrock function using NLopt's LD_LBFGS algorithm.
# Context: Part of NonlinearOptimizationTestFunctions, highlighting TestFunction integration with NLopt.
# Last modified: 11. Juli 2025, 14:10 PM CEST
using NonlinearOptimizationTestFunctions
if isdefined(Main, :NLopt)
    using NLopt
    tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
    n = 2
    opt = Opt(:LD_LBFGS, n)
    NLopt.ftol_rel!(opt, 1e-6)
    NLopt.lower_bounds!(opt, tf.meta[:lb](n))
    NLopt.upper_bounds!(opt, tf.meta[:ub](n))
    NLopt.min_objective!(opt, (x, grad) -> begin
        f = tf.f(x)
        if length(grad) > 0
            tf.gradient!(grad, x)
        end
        f
    end)
    minf, minx, ret = NLopt.optimize(opt, tf.meta[:start](n))
    println("$(tf.meta[:name]): $minx, $minf")
else
    println("NLopt.jl is not installed. Please install it to run this example.")
end