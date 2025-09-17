# test/himmelblau_tests.jl
# Purpose: Tests for the Himmelblau function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: HIMMELBLAU_FUNCTION, himmelblau

@testset "Himmelblau Tests" begin
    tf = HIMMELBLAU_FUNCTION
    n = 2  # Himmelblau ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "himmelblau"
        @test isfinite(himmelblau(tf.meta[:lb]()))
        @test isfinite(himmelblau(tf.meta[:ub]()))
        @test isfinite(himmelblau(fill(1e-308, n)))
        @test isinf(himmelblau(fill(Inf, n)))
        @test himmelblau(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
        @test himmelblau(tf.meta[:start]()) ≈ 170.0 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [3.0, 2.0] atol=1e-6
        @test tf.meta[:min_value]() ≈ 0.0 atol=1e-6
        @test tf.meta[:lb]() == [-5.0, -5.0]
        @test tf.meta[:ub]() == [5.0, 5.0]
        @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    end

    @testset "Optimization Tests" begin
        start = tf.meta[:min_position]() + 0.01 * randn(n)
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-6, iterations=10000, time_limit=120.0)
        )
        minima = [[3.0, 2.0], [-2.805118, 3.131312], [-3.779310, -3.283186], [3.584428, -1.848126]]
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value]() atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError himmelblau(Float64[])
        @test_throws ArgumentError himmelblau([1.0])
        @test_throws ArgumentError himmelblau([1.0, 2.0, 3.0])
        @test isnan(himmelblau(fill(NaN, n)))
        @test isinf(himmelblau(fill(Inf, n)))
        @test isfinite(himmelblau(fill(1e-308, n)))
    end
end