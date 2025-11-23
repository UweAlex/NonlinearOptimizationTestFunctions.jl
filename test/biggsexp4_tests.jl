# test/biggsexp4_tests.jl
# Purpose: Tests for the Biggs EXP4 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for biggsexp4.
# Last modified: November 19, 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP4_FUNCTION, biggsexp4, biggsexp4_gradient

@testset "Biggs EXP4 Tests" begin
    tf = BIGGSEXP4_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "biggsexp4"
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])

    # Test start point
    start_point = tf.meta[:start]()
    @test start_point == [0.01, 0.01, 0.01, 0.01]
    @test biggsexp4(start_point) ≈ 2.8288105116638183 atol=1e-6

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0, 1.0, 5.0] atol=1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ 0.0 atol=1e-6
    @test biggsexp4(min_pos) ≈ min_val atol=1e-6

    # Edge cases
    @test_throws ArgumentError biggsexp4(Float64[])  # Empty vector
    @test isnan(biggsexp4([NaN, 0.0, 0.0, 0.0]))  # NaN input
    @test isinf(biggsexp4([Inf, 0.0, 0.0, 0.0]))  # Inf input
    @test isfinite(biggsexp4([1e-308, 1e-308, 1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError biggsexp4([1.0, 2.0, 3.0])  # Wrong dimension
    @test_throws ArgumentError biggsexp4([1.0, 2.0, 3.0, 4.0, 5.0])  # Wrong dimension

    # Start away from min
    @test tf.f(start_point) > min_val + 1e-3
end