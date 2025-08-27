# test/eggholder_tests.jl
# Purpose: Tests for the Eggholder function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: EGGHOLDER_FUNCTION, eggholder

@testset "Eggholder Tests" begin
    tf = EGGHOLDER_FUNCTION
    n = 2  # Eggholder ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "eggholder"
        @test tf.meta[:in_molga_smutnicki_2005] == false
        @test isfinite(eggholder(tf.meta[:lb]()))
        @test isfinite(eggholder(tf.meta[:ub]()))
        @test isfinite(eggholder(fill(1e-308, n)))
        @test isinf(eggholder(fill(Inf, n)))
        @test eggholder(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-6
        @test eggholder(tf.meta[:start]()) ≈ -25.460337185286313 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() == [512.0, 404.2318058008512]
        @test tf.meta[:min_value] ≈ -959.6406627208506 atol=1e-6
        @test tf.meta[:lb]() == [-512.0, -512.0]
        @test tf.meta[:ub]() == [512.0, 512.0]
        @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    end

    @testset "Optimization Tests" begin
        start = [500.0, 400.0]  # Näher am Minimum für bessere Konvergenz
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
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-3
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-2
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError eggholder(Float64[])
        @test_throws ArgumentError eggholder([1.0])
        @test_throws ArgumentError eggholder([1.0, 2.0, 3.0])
        @test isnan(eggholder(fill(NaN, n)))
        @test isinf(eggholder(fill(Inf, n)))
        @test isfinite(eggholder(fill(1e-308, n)))
    end
end