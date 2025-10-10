# test/mishrabird_tests.jl
# Purpose: Tests for the MishraBird function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: MISHRAbird_FUNCTION, mishrabird

@testset "MishraBird Tests" begin
    tf = MISHRAbird_FUNCTION
    # Minima position
    min_pos1 = [-3.1302468, -1.5821422]

    # Metadata tests for non-scalable function (n=2)
    @test tf.meta[:name] == "mishrabird"
    @test tf.meta[:start]() == [-1.0, -1.0]
    @test tf.meta[:min_position]() ≈ min_pos1 atol=1e-6
    @test tf.meta[:min_value]() ≈ -106.764537 atol=1e-6
    @test tf.meta[:lb]() == [-10.0, -6.5]
    @test tf.meta[:ub]() == [0.0, 0.0]
    @test tf.meta[:properties] == Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"])

    # Function value tests
    start = tf.meta[:start]()
    @test mishrabird(start) ≈ 15.005388 atol=1e-5  # Corrected value at [-1.0, -1.0]
    @test mishrabird(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6

    # Edge case tests
    @test_throws ArgumentError mishrabird(Float64[])  # Empty input
    @test_throws ArgumentError mishrabird([1.0])  # Single element
    @test_throws ArgumentError mishrabird([1.0, 2.0, 3.0])  # Incorrect dimension
    @test isnan(mishrabird([NaN, NaN]))  # NaN input
    @test isinf(mishrabird([Inf, Inf]))  # Inf input
    @test isfinite(mishrabird([1e-308, 1e-308]))  # Small values
    @test isfinite(mishrabird([-10.0, -6.5]))  # Lower bound
    @test isfinite(mishrabird([0.0, 0.0]))  # Upper bound

end