# test/keane_tests.jl
# Purpose: Tests for the Keane function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: KEANE_FUNCTION, keane

@testset "Keane Tests" begin
    tf = KEANE_FUNCTION
    n = 2  # Keane ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "keane"
        
        @test isfinite(keane(tf.meta[:lb]()))
        @test isfinite(keane(tf.meta[:ub]()))
        @test isfinite(keane(fill(1e-308, n)))
        @test isinf(keane(fill(Inf, n)))
        @test keane(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
        @test keane([0.0, 0.0]) ≈ 0.0 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [0.0, 1.39325] atol=1e-6
        @test tf.meta[:min_value]() ≈ -0.673668 atol=1e-6
        @test tf.meta[:lb]() == [0.0, 0.0]
        @test tf.meta[:ub]() == [10.0, 10.0]
        @test tf.meta[:properties] == Set(["multimodal", "continuous", "differentiable", "non-separable", "bounded", "non-convex"])
    end

    @testset "Optimization Tests" begin
        Random.seed!(1234)
        start = clamp.([0.0, 1.4] + 0.01 * randn(n), tf.meta[:lb]().+1e-6, tf.meta[:ub]().-1e-6)
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=10000, time_limit=120.0)
        )
        minima = [[0.0, 1.39325], [1.39325, 0.0]]
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value]() atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError keane(Float64[])
        @test_throws ArgumentError keane([1.0])
        @test_throws ArgumentError keane([1.0, 2.0, 3.0])
        @test isnan(keane(fill(NaN, n)))
        @test isinf(keane(fill(Inf, n)))
        @test isfinite(keane(fill(1e-308, n)))
    end
end