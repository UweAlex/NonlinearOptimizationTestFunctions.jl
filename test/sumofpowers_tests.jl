# test/sumofpowers_tests.jl
# Purpose: Tests for the Sum of Powers function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SUMOFPOWERS_FUNCTION, sumofpowers

@testset "SumOfPowers Tests" begin
    tf = SUMOFPOWERS_FUNCTION
    n = 2

    # Edge Cases
    @test_throws ArgumentError sumofpowers(Float64[])
    @test isnan(sumofpowers(fill(NaN, n)))
    @test isinf(sumofpowers(fill(Inf, n)))
    @test isfinite(sumofpowers(fill(1e-308, n)))

    # Function Values
    @test sumofpowers(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test sumofpowers(tf.meta[:start](n)) ≈ 0.375 atol=1e-6

    # Metadata
    @test tf.meta[:name] == "sumofpowers"
    @test tf.meta[:start](n) == fill(0.5, n)
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == fill(-1.0, n)
    @test tf.meta[:ub](n) == fill(1.0, n)
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "differentiable", "separable", "scalable", "bounded", "continuous"])

    # Optimization Tests
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](n), tf.meta[:ub](n), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=1000))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end