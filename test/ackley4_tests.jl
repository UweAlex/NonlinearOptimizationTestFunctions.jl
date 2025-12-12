# test/ackley4_tests.jl
# Purpose: Tests for the Ackley4 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for ackley4.
# Last modified: 21 September 2025

using Test
using NonlinearOptimizationTestFunctions: ACKLEY4_FUNCTION, ackley4

@testset "Ackley4 Tests" begin
    tf = ACKLEY4_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "ackley4"
    @test tf.meta[:properties] == Set(["multimodal", "controversial", "non-separable", "bounded", "differentiable", "highly multimodal", "continuous", "non-convex"])

    @test tf.meta[:lb]() == [-35.0, -35.0]
    @test tf.meta[:ub]() == [35.0, 35.0]

    # Test start point
    start_point = tf.meta[:start]()

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-1.5812643986108843, -0.7906319137820829] atol = 1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ -5.297009385988958 atol = 1e-6
    @test ackley4(min_pos) ≈ min_val atol = 1e-6

    # Edge cases
    @test_throws ArgumentError ackley4(Float64[])  # Empty vector
    @test isnan(ackley4([NaN, 0.0]))  # NaN input
    @test isinf(ackley4([Inf, 0.0]))  # Inf input
    @test isfinite(ackley4([1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError ackley4([1.0, 2.0, 3.0])  # Wrong dimension
end