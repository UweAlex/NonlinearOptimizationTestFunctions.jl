# test/kearfott_tests.jl
# Purpose: Tests for the Kearfott function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 27, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: KEARFOTT_FUNCTION, kearfott

@testset "Kearfott Tests" begin
    tf = KEARFOTT_FUNCTION
    n = 2  # Kearfott is only defined for n=2

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "kearfott"
        @test tf.meta[:in_molga_smutnicki_2005] == false
        @test isfinite(kearfott(tf.meta[:lb]()))
        @test isfinite(kearfott(tf.meta[:ub]()))
        @test isfinite(kearfott(fill(1e-308, n)))
        @test isinf(kearfott(fill(Inf, n)))
        @test kearfott(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-6
        @test kearfott([0.0, 0.0]) ≈ 4.25 atol=1e-6  # (0² + 0² - 2)² + (0² + 0² - 0.5)² = 4 + 0.25 = 4.25
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [0.7905694150420949, -0.7905694150420949] atol=1e-6
        @test tf.meta[:min_value] ≈ 1.125 atol=1e-6
        @test tf.meta[:lb]() == [-3.0, -3.0]
        @test tf.meta[:ub]() == [4.0, 4.0]
        @test tf.meta[:properties] == Set(["multimodal", "continuous", "differentiable", "non-separable", "bounded", "non-convex"])
    end

    @testset "Optimization Tests" begin
        start = [0.7905694150420949, -0.7905694150420949]  # Correct global minimum
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-6, g_tol=1e-8, iterations=10000, time_limit=120.0)
        )
        minima = [[0.7905694150420949, -0.7905694150420949], [-0.7905694150420949, 0.7905694150420949]]
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError kearfott(Float64[])
        @test_throws ArgumentError kearfott([1.0])
        @test_throws ArgumentError kearfott([1.0, 2.0, 3.0])
        @test isnan(kearfott(fill(NaN, n)))
        @test isinf(kearfott(fill(Inf, n)))
        @test isfinite(kearfott(fill(1e-308, n)))
    end
end