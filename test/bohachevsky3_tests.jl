# test/bohachevsky3_tests.jl
# Purpose: Tests for the Bohachevsky 3 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies metadata, function values, and edge cases.
# Last modified: 18 September 2025, 09:40 AM CEST

using Test
using NonlinearOptimizationTestFunctions: BOHACHEVSKY3_FUNCTION, bohachevsky3
using LinearAlgebra

@testset "Bohachevsky 3 Tests" begin
    tf = BOHACHEVSKY3_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "bohachevsky3"
    @test tf.meta[:start]() == [0.01, 0.01]
    @test tf.meta[:min_position]() == [0.0, 0.0]
    @test tf.meta[:min_value]() == 0.0
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
    @test tf.meta[:properties] == Set(["continuous", "differentiable", "multimodal", "non-convex", "non-separable", "bounded"])

    # Test function value at start point
    @test bohachevsky3([0.01, 0.01]) ≈ 0.00752497141837577 atol=1e-6

    # Test function value at minimum
    @test bohachevsky3([0.0, 0.0]) ≈ 0.0 atol=1e-6

    # Test edge cases
    @test_throws ArgumentError bohachevsky3(Float64[])
    @test_throws ArgumentError bohachevsky3([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(bohachevsky3([NaN, 0.0]))
    @test isinf(bohachevsky3([Inf, 0.0]))
    @test isfinite(bohachevsky3([-100.0, -100.0]))  # Lower bound
    @test isfinite(bohachevsky3([100.0, 100.0]))    # Upper bound
    @test isfinite(bohachevsky3([1e-308, 1e-308]))
end