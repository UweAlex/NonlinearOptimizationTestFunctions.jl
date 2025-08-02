# test/goldsteinprice_tests.jl
# Purpose: Tests for the Goldstein-Price function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 18. Juli 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: GOLDSTEINPRICE_FUNCTION, goldsteinprice

@testset "Goldstein-Price Tests" begin
    tf = GOLDSTEINPRICE_FUNCTION
    n = 2
    @test_throws ArgumentError goldsteinprice(Float64[])
    @test_throws ArgumentError goldsteinprice([1.0, 1.0, 1.0])
    @test isnan(goldsteinprice([NaN, NaN]))
    @test isinf(goldsteinprice([Inf, Inf]))
    @test isfinite(goldsteinprice([1e-308, 1e-308]))
    @test goldsteinprice(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test goldsteinprice(tf.meta[:start](n)) ≈ 600.0 atol=1e-6
    @test tf.meta[:name] == "goldsteinprice"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [0.0, -1.0]
    @test tf.meta[:min_value] ≈ 3.0 atol=1e-6
    @test tf.meta[:lb](n) == [-2.0, -2.0]
    @test tf.meta[:ub](n) == [2.0, 2.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Start nahe Minimum wegen Multimodalität
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end