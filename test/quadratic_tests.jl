# test/quadratic_tests.jl
# Purpose: Tests for the Quadratic function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: QUADRATIC_FUNCTION, quadratic

@testset "Quadratic Tests" begin
    tf = QUADRATIC_FUNCTION
    n = 2  # Default dimension for metadata tests

    # Metadata tests
    @test tf.meta[:name] == "quadratic"
    @test tf.meta[:start](n) == zeros(n)
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:min_value](n) == 0.0
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test tf.meta[:properties] == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable", "continuous"])

    # Function value tests
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    @test quadratic(start) ≈ tf.meta[:min_value](n) atol=1e-6
    @test quadratic(min_pos) ≈ tf.meta[:min_value](n) atol=1e-6

    # Edge case tests
    @test_throws ArgumentError quadratic(Float64[])
    @test isnan(quadratic([NaN, NaN]))
    @test isinf(quadratic([Inf, Inf]))
    @test isfinite(quadratic([1e-308, 1e-308]))
    @test isfinite(quadratic(zeros(n)))

    # Optimization tests
    @testset "Optimization Tests" begin
        for n in [2, 5]
            start = tf.meta[:start](n)
            # Ensure parameters are initialized for this dimension
            quadratic(start)  # Initialize A_fixed, b_fixed, c_fixed
            result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-8))
            minimizer = Optim.minimizer(result)
            @test Optim.minimum(result) ≈ tf.meta[:min_value](n) atol=1e-5
            @test isapprox(minimizer, tf.meta[:min_position](n), atol=1e-3)
        end
    end
end