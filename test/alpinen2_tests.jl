# test/alpinen2_tests.jl
# Purpose: Tests for the AlpineN2 function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 28 August 2025

using Test, NonlinearOptimizationTestFunctions

using NonlinearOptimizationTestFunctions: ALPINEN2_FUNCTION, alpinen2, alpinen2_gradient

@testset "AlpineN2 Tests" begin
    tf = ALPINEN2_FUNCTION
    n = 2

    # Test metadata
    @test tf.meta[:name] == "alpinen2"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"])

    # Test function values
    @test alpinen2(tf.meta[:min_position](n)) ≈ -2.8081311800070053^n atol=1e-6
    @test alpinen2([1.0, 1.0]) ≈ -prod(sqrt(1.0) * sin(1.0) for _ in 1:n) atol=1e-6

    # Test edge cases
    @test_throws ArgumentError alpinen2(Float64[])
    @test isnan(alpinen2([NaN, 1.0]))
    @test isfinite(alpinen2(tf.meta[:lb](n)))
    @test isfinite(alpinen2(tf.meta[:ub](n)))
    @test isfinite(alpinen2(fill(1e-308, n)))

   
end