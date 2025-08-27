# test/dropwave_tests.jl
# Purpose: Tests for the Drop-Wave function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: DROPWAVE_FUNCTION, dropwave
using Random

@testset "Drop-Wave Tests" begin
    tf = DROPWAVE_FUNCTION
    n = 2  # Drop-Wave ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "dropwave"
        @test tf.meta[:in_molga_smutnicki_2005] == true
        @test isfinite(dropwave(tf.meta[:lb]()))
        @test isfinite(dropwave(tf.meta[:ub]()))
        @test isfinite(dropwave(fill(1e-308, n)))
        @test isinf(dropwave(fill(Inf, n)))
        @test dropwave(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-3
        x_start = tf.meta[:start]()  # [1.0, 1.0]
        r = sqrt(2.0)  # sqrt(1^2 + 1^2)
        expected_value = -(1 + cos(12 * r)) / (0.5 * 2 + 2)
        @test dropwave(x_start) ≈ expected_value atol=1e-6
        @test tf.meta[:start]() == [1.0, 1.0]
        @test tf.meta[:min_position]() == [0.0, 0.0]
        @test tf.meta[:min_value] ≈ -1.0 atol=1e-6
        @test tf.meta[:lb]() == [-5.12, -5.12]
        @test tf.meta[:ub]() == [5.12, 5.12]
        @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    end

    @testset "Optimization Tests" begin
        Random.seed!(1234)
        start = tf.meta[:min_position]() + 0.01 * randn(n)  # Leichte Störung für multimodale Funktion
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-6, iterations=10000, time_limit=120.0)
        )
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError dropwave(Float64[])
        @test_throws ArgumentError dropwave([1.0])
        @test_throws ArgumentError dropwave([1.0, 2.0, 3.0])
        @test isnan(dropwave(fill(NaN, n)))
        @test isinf(dropwave(fill(Inf, n)))
        @test isfinite(dropwave(fill(1e-308, n)))
    end
end