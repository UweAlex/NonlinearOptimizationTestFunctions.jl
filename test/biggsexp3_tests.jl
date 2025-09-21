# test/biggsexp3_tests.jl
# Purpose: Tests for the Biggs EXP3 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for biggsexp3.
# Last modified: 21 September 2025, 08:00 PM CEST

using Test
using NonlinearOptimizationTestFunctions

@testset "Biggs EXP3 Tests" begin
    tf = BIGGSEXP3_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "biggsexp3"
    @test tf.meta[:properties] == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])
    @test tf.meta[:lb]() == [0.0, 0.0, 0.0]
    @test tf.meta[:ub]() == [20.0, 20.0, 20.0]

    # Test start point
    start_point = tf.meta[:start]()
    @test start_point == [0.01, 0.01, 0.01]
    @test biggsexp3(start_point) ≈ 6.429960046006889 atol=1e-6  # Manually computed or executed value

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0, 5.0] atol=1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ 0.0 atol=1e-6
    @test biggsexp3(min_pos) ≈ min_val atol=1e-6

    # Additional numerical tests
    @test biggsexp3([0.0, 0.0, 0.0]) ≈ 6.627489158423668 atol=1e-6  # Value at lower bound
    @test biggsexp3([20.0, 20.0, 20.0]) ≈ 4.911628400681332 atol=1e-6  # Value at upper bound
    @test biggsexp3([1.0, 1.0, 1.0]) ≈ 2.8288105116638183 atol=1e-6  # Value at [1,1,1]
    @test biggsexp3([2.0, 20.0, 10.0]) ≈ 0.627786625746647 atol=1e-6  # Value at double the minimum coordinates

    # Edge cases
    @test_throws ArgumentError biggsexp3(Float64[])  # Empty vector
    @test isnan(biggsexp3([NaN, 0.0, 0.0]))  # NaN input
    @test isinf(biggsexp3([Inf, 0.0, 0.0]))  # Inf input
    @test isfinite(biggsexp3([1e-308, 1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError biggsexp3([1.0, 2.0])  # Wrong dimension
end