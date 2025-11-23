# test/biggsexp6_tests.jl
# Purpose: Tests for the Biggs EXP6 test function.
# Last modified: November 19, 2025

using Test
using NonlinearOptimizationTestFunctions: BIGGSEXP6_FUNCTION, biggsexp6, biggsexp6_gradient

@testset "Biggs EXP6 Tests" begin
    tf = BIGGSEXP6_FUNCTION

    # Metadata
    @test tf.meta[:name] == "biggsexp6"
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"])

    # Start & Min
    start = tf.meta[:start]()
    @test start ≈ [1.0, 2.0, 1.0, 1.0, 1.0, 1.0] atol=1e-12
    @test biggsexp6(start) ≈ 0.779 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 10.0, 1.0, 5.0, 4.0, 3.0] atol=1e-6
    @test biggsexp6(min_pos) ≈ 0.0 atol=1e-10
    @test tf.meta[:min_value]() ≈ 0.0 atol=1e-10

    # Bounds
    @test tf.meta[:lb]() == fill(-20.0, 6)
    @test tf.meta[:ub]() == fill(20.0, 6)

    # Edge cases
    @test_throws ArgumentError biggsexp6(Float64[])
    @test isnan(biggsexp6([NaN, 0, 0, 0, 0, 0]))
    @test isinf(biggsexp6([Inf, 0, 0, 0, 0, 0]))
    @test isfinite(biggsexp6(fill(1e-308, 6)))
    @test_throws ArgumentError biggsexp6(ones(5))
    @test_throws ArgumentError biggsexp6(ones(7))

    # Start away from min
    @test tf.f(start) > tf.meta[:min_value]() + 1e-3
end