# test/giunta_tests.jl
using Test, NonlinearOptimizationTestFunctions, Optim

@testset "Giunta Function Tests" begin
    tf = NonlinearOptimizationTestFunctions.GIUNTA_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    @test tf.f(start) ≈ 0.363477 atol=1e-6
    @test tf.f(min_pos) ≈ tf.meta[:min_value] atol=1e-6
    @test tf.grad(min_pos) ≈ [0.0, 0.0] atol=1e-6
    @test_throws ArgumentError tf.f(zeros(3))
    result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
    @test isapprox(tf.f(Optim.minimizer(result)), tf.meta[:min_value], atol=1e-3)
end