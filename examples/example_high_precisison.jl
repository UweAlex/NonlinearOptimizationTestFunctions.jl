# example_high_precisison.jl
using NonlinearOptimizationTestFunctions
using Optim
using Base.MPFR

setprecision(BigFloat, 256)

tf = WAYBURNSEADER1_FUNCTION
x0 = BigFloat[0, 0]
options = Optim.Options(g_tol=BigFloat(1e-100))
result = Optim.optimize(tf.f, tf.gradient!, x0, Optim.LBFGS(), options)
println(Optim.minimizer(result))
println(Optim.minimum(result))