# test/biggsexp3_tests.jl
# Purpose: Tests for the Biggs EXP3 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for biggsexp3.
# Last modified: November 17, 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP3_FUNCTION, biggsexp3, biggsexp3_gradient

@testset "Biggs EXP3 Tests" begin
    tf = BIGGSEXP3_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "biggsexp3"
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])

    # Test start point
    start_point = tf.meta[:start]()
    @test start_point == [0.01, 0.01, 0.01]
    @test biggsexp3(start_point) ≈ 6.429960046006889 atol=1e-6

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0, 5.0] atol=1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ 0.0 atol=1e-6
    @test biggsexp3(min_pos) ≈ min_val atol=1e-6

    # Edge cases
    @test_throws ArgumentError biggsexp3(Float64[])  # Empty vector
    @test isnan(biggsexp3([NaN, 0.0, 0.0]))  # NaN input
    @test isinf(biggsexp3([Inf, 0.0, 0.0]))  # Inf input
    @test isfinite(biggsexp3([1e-308, 1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError biggsexp3([1.0, 2.0])  # Wrong dimension
    @test_throws ArgumentError biggsexp3([1.0, 2.0, 3.0, 4.0])  # Wrong dimension

    # Start away from min
    @test tf.f(start_point) > min_val + 1e-3
end