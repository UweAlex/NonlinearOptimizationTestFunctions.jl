# test/dixonprice_tests.jl
# Purpose: Tests for the Dixon-Price function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: DIXONPRICE_FUNCTION, dixonprice

@testset "Dixon-Price Tests" begin
    tf = DIXONPRICE_FUNCTION
    n = 2  # Standard dimension
    @test_throws ArgumentError dixonprice(Float64[])
    @test isnan(dixonprice(fill(NaN, n)))
    @test isinf(dixonprice(fill(Inf, n)))
    @test isfinite(dixonprice(fill(1e-308, n)))
    @test dixonprice(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test dixonprice(tf.meta[:start](n)) ≈ 2.0 atol=1e-6
    @test tf.meta[:name] == "dixonprice"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) ≈ [1.0, 2^(-0.5)] atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "scalable", "unimodal" ,"bounded","continuous"])
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end