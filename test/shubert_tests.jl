# test/shubert_tests.jl
# Purpose: Tests for the Shubert function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 19. Juli 2025

using Test, LinearAlgebra
using NonlinearOptimizationTestFunctions: SHUBERT_FUNCTION, shubert, shubert_gradient

@testset "Shubert Tests" begin
    tf = SHUBERT_FUNCTION
    n = 2
    @test_throws ArgumentError shubert(Float64[])
    @test_throws ArgumentError shubert([1.0, 2.0, 3.0])
    @test isnan(shubert([NaN, 0.0]))
    @test isinf(shubert([Inf, 0.0]))
    @test isfinite(shubert([1e-308, 1e-308]))
    @test shubert(tf.meta[:min_position](n)) ≈ -186.730908831 atol=1e-5
    @test shubert(tf.meta[:start](n)) ≈ 19.8758362498 atol=1e-5
    @test tf.meta[:name] == "shubert"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) ≈ [-1.4251286, -0.800321] atol=1e-6
    @test tf.meta[:min_value]() ≈ -186.730908831 atol=1e-5
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded","continuous"])
    @testset "Minimum Verification" begin
        min_pos = tf.meta[:min_position](n)
        @test shubert(min_pos) ≈ -186.730908831 atol=1e-5
        @test norm(shubert_gradient(min_pos)) < 1e-3
    end
end