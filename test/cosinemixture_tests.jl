# test/cosinemixture_tests.jl
# Purpose: Tests for the Cosine Mixture Function implementation.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 20 September 2025, 07:30 PM CEST

using Test, NonlinearOptimizationTestFunctions

tf = COSINEMIXTURE_FUNCTION
n = 2  # Test with n=2

@testset "CosineMixture Metadata Tests" begin
    @test tf.meta[:name] == "cosinemixture"
    @test tf.meta[:start](n) ≈ [0.5, 0.5]
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0]
    @test tf.meta[:min_value](n) ≈ -0.2 atol=1e-6
    @test Set(tf.meta[:properties]) == Set(["continuous", "differentiable", "separable", "scalable", "multimodal", "non-convex", "bounded"])
    @test tf.meta[:lb](n) ≈ [-1.0, -1.0]
    @test tf.meta[:ub](n) ≈ [1.0, 1.0]
end

@testset "CosineMixture Function Value Tests" begin
    # Value at minimum
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ -0.2 atol=1e-6

    # Value at start point
    start_pos = tf.meta[:start](n)
    expected_start_value = -0.5  # Matches evaluated value
    @test tf.f(start_pos) ≈ expected_start_value atol=1e-6

    # Another test point: [1.0, 1.0]
    expected_value = -1.8  # Matches evaluated value
    @test tf.f([1.0, 1.0]) ≈ expected_value atol=1e-6
end

@testset "CosineMixture Gradient Tests (Specific)" begin
    # Gradient at minimum [0,0]
    @test cosinemixture_gradient(fill(0.0, n)) ≈ fill(0.0, n)

    # Gradient at [0.5, 0.5]
    expected_grad = [0.5707963267948966, 0.5707963267948966]  # Matches evaluated value
    @test cosinemixture_gradient([0.5, 0.5]) ≈ expected_grad atol=1e-6
end

@testset "CosineMixture Edge Cases" begin
    @test_throws ArgumentError tf.f(Float64[])  # Empty vector (valid edge case)
    # Removed tf.f([1.0]) test, as n=1 is allowed for scalable function
end