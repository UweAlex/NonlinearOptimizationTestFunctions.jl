# test/rotatedhyperellipsoid_tests.jl
# Purpose: Tests for the Rotated Hyper-Ellipsoid function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: ROTATEDHYPERELLIPSOID_FUNCTION, rotatedhyperellipsoid, rotatedhyperellipsoid_gradient

@testset "RotatedHyperEllipsoid Tests" begin
    tf = ROTATEDHYPERELLIPSOID_FUNCTION
    n = 2

    # Edge case tests
    @test_throws ArgumentError rotatedhyperellipsoid(Float64[])
    @test isnan(rotatedhyperellipsoid(fill(NaN, n)))
    @test isinf(rotatedhyperellipsoid(fill(Inf, n)))
    @test isfinite(rotatedhyperellipsoid(fill(1e-308, n)))

    # Function value tests
    @test rotatedhyperellipsoid(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol=1e-6
    @test rotatedhyperellipsoid(tf.meta[:start](n)) ≈ 5.0 atol=1e-6  # (1)^2 + (1+1)^2 = 1 + 4 = 5

    # Metadata tests
    @test tf.meta[:name] == "rotatedhyperellipsoid"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value](n) ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-65.536, -65.536]
    @test tf.meta[:ub](n) == [65.536, 65.536]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable", "bounded", "continuous"])

    # Gradient test
    @test rotatedhyperellipsoid_gradient([1.0, 1.0]) ≈ [6.0, 4.0] atol=1e-6  # For n=2: [2*(1+2), 2*2]

    # Optimization tests
    @testset "Optimization Tests" begin
        for n in [2, 5]
            start = fill(0.1, n)  # Closer to minimum
            result = optimize(tf.f, tf.gradient!, tf.meta[:lb](n), tf.meta[:ub](n), start, Fminbox(GradientDescent()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=5000))
            @test Optim.converged(result)  # Check convergence
            @test Optim.minimum(result) ≈ tf.meta[:min_value](n) atol=1e-5
            @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
        end
    end

    # Additional test for higher dimension (scalable)
    n_high = 10
    @test rotatedhyperellipsoid(tf.meta[:min_position](n_high)) ≈ tf.meta[:min_value](n) atol=1e-6
end