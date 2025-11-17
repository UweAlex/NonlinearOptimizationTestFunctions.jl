# test/bartelsconn_tests.jl
# Purpose: Tests for the BartelsConn function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: November 17, 2025

using Test, Random
using NonlinearOptimizationTestFunctions: BARTELSCONN_FUNCTION, bartelsconn, bartelsconn_gradient

@testset "BartelsConn Tests" begin
    tf = BARTELSCONN_FUNCTION
    n = 2  # BartelsConn is fixed to n=2
    Random.seed!(1234)  # For reproducible perturbation

    # Edge Cases
    @test_throws ArgumentError bartelsconn(Float64[])
    @test_throws ArgumentError bartelsconn([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(bartelsconn([NaN, 0.0]))
    @test isinf(bartelsconn([Inf, 0.0]))
    @test isfinite(bartelsconn([1e-308, 1e-308]))

    # Function values
    @test bartelsconn(tf.meta[:min_position]()) ≈ 1.0 atol=1e-6
    @test bartelsconn(tf.meta[:start]()) ≈ 4.381773290676036 atol=1e-6  # Value at start point [1.0, 1.0]

    # Metadata
    @test tf.meta[:name] == "bartelsconn"
    @test tf.meta[:start]() == [1.0, 1.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value]() ≈ 1.0 atol=1e-6
    @test tf.meta[:lb]() == [-500.0, -500.0]
    @test tf.meta[:ub]() == [500.0, 500.0]
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "partially differentiable", "bounded", "continuous"])

    # Subgradient test (angepasst: NaN bei non-diff-Punkten, per [RULE_ERROR_HANDLING])
    @test all(isnan.(bartelsconn_gradient([0.0, 0.0])))  # Returns NaN at non-differentiable minimum
end