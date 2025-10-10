# test/levyjamil_tests.jl
# Purpose: Tests for the Levy function (Jamil & Yang, 2013).
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: September 05, 2025

using Test
using Optim
using Random
using NonlinearOptimizationTestFunctions: LEVYJAMIL_FUNCTION, levyjamil

@testset "Levy Jamil Tests" begin
    tf = LEVYJAMIL_FUNCTION
    n = 2  # Standard dimension
    # Edge case tests
    @test_throws ArgumentError levyjamil(Float64[])
    @test isnan(levyjamil(fill(NaN, n)))
    @test isinf(levyjamil(fill(Inf, n)))
    @test isfinite(levyjamil(fill(1e-308, n)))
    # Function value tests
    @test levyjamil(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol=1e-5
    @test levyjamil(tf.meta[:start](n)) ≈ 2.0 atol=1e-6  # f(0,0) = 2.0 for Jamil & Yang (2013)
    # Metadata tests
    @test tf.meta[:name] == "levyjamil"
    @test tf.meta[:start](n) == zeros(n)
    @test tf.meta[:min_position](n) == [1.0, 1.0]
    @test tf.meta[:min_value](n) ≈ 0.0 atol=1e-5
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "scalable", "multimodal", "bounded", "continuous"])
 
end