# test/biggsexp2_tests.jl
# Purpose: Tests for the Biggs EXP2 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for biggsexp2.
# Last modified: 21 September 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP2_FUNCTION, biggsexp2
# test/biggsexp2_tests.jl
# Purpose: Tests for the Biggs EXP2 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases for biggsexp2.
# Last modified: November 17, 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP2_FUNCTION, biggsexp2, biggsexp2_gradient

@testset "Biggs EXP2 Tests" begin
    tf = BIGGSEXP2_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "biggsexp2"
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])
    @test tf.meta[:lb]() == [0.0, 0.0]
    @test tf.meta[:ub]() == [20.0, 20.0]

    # Test start point
    start_point = tf.meta[:start]()
    @test start_point == [0.01, 0.01]
    @test biggsexp2(start_point) ≈ 185.6984004135975 atol=1e-6

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0] atol=1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ 0.0 atol=1e-6
    @test biggsexp2(min_pos) ≈ min_val atol=1e-6

    # Edge cases
    @test_throws ArgumentError biggsexp2(Float64[])  # Empty vector
    @test isnan(biggsexp2([NaN, 0.0]))  # NaN input
    @test isinf(biggsexp2([Inf, 0.0]))  # Inf input
    @test isfinite(biggsexp2([1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError biggsexp2([1.0, 2.0, 3.0])  # Wrong dimension

    # Start away from min
    @test tf.f(start_point) > min_val + 1e-3
end
@testset "Biggs EXP2 Tests" begin
    tf = BIGGSEXP2_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "biggsexp2"
    @test tf.meta[:properties] == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])
    @test tf.meta[:lb]() == [0.0, 0.0]
    @test tf.meta[:ub]() == [20.0, 20.0]

    # Test start point
    start_point = tf.meta[:start]()
    @test start_point == [0.01, 0.01]
    @test biggsexp2(start_point) ≈ 185.6984004135975 atol=1e-6  # Manually computed or executed value

    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0] atol=1e-6
    min_val = tf.meta[:min_value]()
    @test min_val ≈ 0.0 atol=1e-6
    @test biggsexp2(min_pos) ≈ min_val atol=1e-6

    # Edge cases
    @test_throws ArgumentError biggsexp2(Float64[])  # Empty vector
    @test isnan(biggsexp2([NaN, 0.0]))  # NaN input
    @test isinf(biggsexp2([Inf, 0.0]))  # Inf input
    @test isfinite(biggsexp2([1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError biggsexp2([1.0, 2.0, 3.0])  # Wrong dimension
end