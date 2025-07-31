# test/sixhumpcamelback_tests.jl
# Purpose: Tests for the Six-Hump Camelback function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 19 July 2025

using Test, Optim
using NonlinearOptimizationTestFunctionsInJulia: SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback

@testset "Six-Hump Camelback Tests" begin
    tf = SIXHUMPCAMELBACK_FUNCTION
    n = 2
    @test_throws ArgumentError sixhumpcamelback(Float64[])
    @test_throws ArgumentError sixhumpcamelback([1.0, 2.0, 3.0])
    @test isnan(sixhumpcamelback(fill(NaN, n)))
    @test isinf(sixhumpcamelback(fill(Inf, n)))
    @test isfinite(sixhumpcamelback(fill(1e-308, n)))
    @test sixhumpcamelback(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test sixhumpcamelback([0.0, 0.0]) ≈ 0.0 atol=1e-6
    @test tf.meta[:name] == "sixhumpcamelback"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [-0.08984201368301331, 0.7126564032704135]
    @test tf.meta[:min_value] ≈ -1.031628453489877 atol=1e-6
    @test tf.meta[:lb](n) == [-3.0, -2.0]
    @test tf.meta[:ub](n) == [3.0, 2.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Start near a minimum
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        minima = [[-0.08984201368301331, 0.7126564032704135], [0.08984201368301331, -0.7126564032704135]]  # Both global minima
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end
end