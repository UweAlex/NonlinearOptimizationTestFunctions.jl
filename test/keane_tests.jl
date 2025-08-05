# test/keane_tests.jl
# Purpose: Tests for the Keane function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 05 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: KEANE_FUNCTION, keane

@testset "Keane Tests" begin
    tf = KEANE_FUNCTION
    n = 2
    @test_throws ArgumentError keane(Float64[])
    @test isnan(keane(fill(NaN, n)))
    @test isinf(keane(fill(Inf, n)))
    @test isfinite(keane(fill(1e-308, n)))
    @test keane(tf.meta[:min_position](n)) ≈ -0.673667521146855 atol=1e-6
    @test keane(tf.meta[:start](n)) ≈ 0.0 atol=1e-6
    @test tf.meta[:name] == "keane"
    @test tf.meta[:start](n) == [0.5, 0.5]
    @test tf.meta[:min_position](n) == [0.0, 1.393249070031784]
    @test tf.meta[:min_value] ≈ -0.673667521146855 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        minima = [[0.0, 1.393249070031784], [1.393249070031784, 0.0]]
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end
end