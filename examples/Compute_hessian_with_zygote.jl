# examples/Compute_hessian_with_zygote.jl
# Purpose: Shows 3 Newton steps on Rosenbrock using analytical gradients and Zygote's Hessian.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, for experts.
# Last modified: 11. Juli 2025, 14:10 PM CEST
using NonlinearOptimizationTestFunctionsInJulia, Zygote, LinearAlgebra
tf = NonlinearOptimizationTestFunctionsInJulia.ROSENBROCK_FUNCTION
n = 2
x = tf.meta[:start](n)
x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
println("Nach 3 Newton-Schritten für $(tf.meta[:name]): $x")