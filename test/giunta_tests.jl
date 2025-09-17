# test/giunta_tests.jl
# Purpose: Tests for the Giunta function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: GIUNTA_FUNCTION, giunta

@testset "Giunta Function Tests" begin
    tf = GIUNTA_FUNCTION
    n = 2  # Giunta ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "giunta"
        @test tf.meta[:in_molga_smutnicki_2005] == false
        @test isfinite(giunta(tf.meta[:lb]()))
        @test isfinite(giunta(tf.meta[:ub]()))
        @test isfinite(giunta(fill(1e-308, n)))
        @test isinf(giunta(fill(Inf, n)))
        @test giunta(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
        @test giunta(tf.meta[:start]()) ≈ 0.363477 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [0.46732002530945826, 0.46732002530945826] atol=1e-6
        @test tf.meta[:min_value]() ≈ 0.06447042053690566 atol=1e-6
        @test tf.meta[:lb]() == [-1.0, -1.0]
        @test tf.meta[:ub]() == [1.0, 1.0]
        @test tf.meta[:properties] == Set(["multimodal", "non-convex", "separable", "differentiable", "bounded", "continuous"])
    end

    @testset "Gradient Norm Minimization" begin
        # Minimierung des Quadrats des Gradienten, um das Minimum zu bestätigen
        function grad_norm_squared(x)
            grad = tf.grad(x)
            return dot(grad, grad)
        end
        start = [0.467, 0.467]
        result = optimize(
            grad_norm_squared,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-8, iterations=10000)
        )
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ 0.0 atol=1e-6  # Gradient sollte null sein
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-4
        @test tf.f(Optim.minimizer(result)) ≈ tf.meta[:min_value]() atol=1e-6
    end

    @testset "Optimization Tests" begin
        start = [0.467, 0.467]  # Näher am Minimum für bessere Konvergenz
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-8, iterations=10000, time_limit=120.0)
        )
        @test Optim.converged(result)
        @test tf.f(Optim.minimizer(result)) ≈ tf.meta[:min_value]() atol=1e-6
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-4
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError giunta(Float64[])
        @test_throws ArgumentError giunta([1.0])
        @test_throws ArgumentError giunta([1.0, 2.0, 3.0])
        @test isnan(giunta(fill(NaN, n)))
        @test isinf(giunta(fill(Inf, n)))
        @test isfinite(giunta(fill(1e-308, n)))
    end
end