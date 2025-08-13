# test/rotatedhyperellipsoid_tests.jl
# Purpose: Tests for the Rotated Hyper-Ellipsoid function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 13. August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: ROTATEDHYPERELLIPSOID_FUNCTION, rotatedhyperellipsoid

@testset "RotatedHyperEllipsoid Tests" begin
    tf = ROTATEDHYPERELLIPSOID_FUNCTION
    n = 2
    @test_throws ArgumentError rotatedhyperellipsoid(Float64[])
    @test isnan(rotatedhyperellipsoid(fill(NaN, n)))
    @test isinf(rotatedhyperellipsoid(fill(Inf, n)))
    @test isfinite(rotatedhyperellipsoid(fill(1e-308, n)))
    @test rotatedhyperellipsoid(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test rotatedhyperellipsoid(tf.meta[:start](n)) ≈ 5.0 atol=1e-6  # Calculated: (1)^2 + (1+1)^2 = 1 + 4 = 5
    @test tf.meta[:name] == "rotatedhyperellipsoid"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-65.536, -65.536]
    @test tf.meta[:ub](n) == [65.536, 65.536]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable"])
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
    # Additional test for higher dimension (scalable)
    n_high = 10
    @test rotatedhyperellipsoid(tf.meta[:min_position](n_high)) ≈ tf.meta[:min_value] atol=1e-6
end