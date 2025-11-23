# test/biggsexp5_tests.jl
# Purpose: Tests for the Biggs EXP5 test function.
# Last modified: November 19, 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP5_FUNCTION, biggsexp5, biggsexp5_gradient

@testset "Biggs EXP5 Tests" begin
    tf = BIGGSEXP5_FUNCTION

    # Metadata
    @test tf.meta[:name] == "biggsexp5"
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])

    # Start & Min
    start = tf.meta[:start]()
    @test start == [0.01, 0.01, 0.01, 0.01, 0.01]
    @test biggsexp5(start) ≈ 51.01256044522263 atol=1e-6

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0, 1.0, 5.0, 4.0] atol=1e-6
    @test biggsexp5(min_pos) ≈ 0.0 atol=1e-10
    @test tf.meta[:min_value]() ≈ 0.0 atol=1e-10

    # Bounds
    @test tf.meta[:lb]() == [0.0, 0.0, 0.0, 0.0, 0.0]
    @test tf.meta[:ub]() == [20.0, 20.0, 20.0, 20.0, 20.0]

    # Edge cases
    @test_throws ArgumentError biggsexp5(Float64[])
    @test isnan(biggsexp5([NaN, 0.0, 0.0, 0.0, 0.0]))
    @test isinf(biggsexp5([Inf, 0.0, 0.0, 0.0, 0.0]))
    @test isfinite(biggsexp5(fill(1e-308, 5)))
    @test_throws ArgumentError biggsexp5(ones(4))
    @test_throws ArgumentError biggsexp5(ones(6))

    # Start away from min
    @test tf.f(start) > tf.meta[:min_value]() + 1e-3
end