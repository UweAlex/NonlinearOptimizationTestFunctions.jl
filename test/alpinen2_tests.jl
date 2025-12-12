# test/alpinen2_tests.jl
# Purpose: Tests for the AlpineN2 function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: November 18, 2025

using Test, NonlinearOptimizationTestFunctions

using NonlinearOptimizationTestFunctions: ALPINEN2_FUNCTION, alpinen2, alpinen2_gradient

@testset "AlpineN2 Tests" begin
    tf = ALPINEN2_FUNCTION
    n = tf.meta[:default_n]

    # Test metadata
    @test tf.meta[:name] == "alpinen2"
    @test Set(tf.meta[:properties]) == Set(["multimodal", "separable", "bounded", "differentiable", "continuous", "scalable", "non-convex"])

    # Test function values
    @test alpinen2(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol = 1e-6
    @test alpinen2([1.0, 1.0]) ≈ -prod(sqrt(1.0) * sin(1.0) for _ in 1:n) atol = 1e-6

    # Test edge cases
    @test_throws ArgumentError alpinen2(Float64[])
    @test isnan(alpinen2([NaN, 1.0]))
    @test isfinite(alpinen2(tf.meta[:lb](n)))
    @test isfinite(alpinen2(tf.meta[:ub](n)))
    @test isfinite(alpinen2(fill(1e-308, n)))
end