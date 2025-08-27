# test/dejongf4_tests.jl
# Purpose: Tests for the De Jong F4 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization for dejongf4.jl.
# Last modified: 26 August 2025

using Test
using Optim
using ForwardDiff
using LinearAlgebra
using NonlinearOptimizationTestFunctions: DEJONGF4_FUNCTION, dejongf4, dejongf4_gradient

@testset "De Jong F4 Tests" begin
    tf = DEJONGF4_FUNCTION
    n = 2  # Test dimension

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "dejongf4"
        @test isfinite(dejongf4(tf.meta[:lb](n); noise=0.0))
        @test isfinite(dejongf4(tf.meta[:ub](n); noise=0.0))
        @test tf.meta[:min_value] ≈ 0.0 atol=1e-3
        @test dejongf4(tf.meta[:min_position](n); noise=0.0) ≈ tf.meta[:min_value] atol=1e-3 rtol=1e-2
        @test 0.0 <= dejongf4(tf.meta[:start](n); noise=0.0) < 1.0
        @test tf.meta[:start](n) == zeros(Float64, n)
        @test tf.meta[:min_position](n) ≈ zeros(Float64, n) atol=1e-3
        @test tf.meta[:properties] == Set(["unimodal", "convex", "separable", "partially differentiable", "scalable", "continuous", "bounded", "has_noise"])
        @test tf.meta[:lb](n) == fill(-1.28, n)
        @test tf.meta[:ub](n) == fill(1.28, n)
    end

    @testset "Optimization Tests" begin
        res = optimize(x -> dejongf4(x; noise=0.0), tf.meta[:start](n), NelderMead(), Optim.Options(iterations=1000))
        @test Optim.converged(res)
        @test Optim.minimum(res) ≈ tf.meta[:min_value] atol=1e-2 rtol=1e-2
        @test Optim.minimizer(res) ≈ tf.meta[:min_position](n) atol=1e-2
    end

    @testset "Gradient Comparison Tests" begin
        lb = tf.meta[:lb](n)
        ub = tf.meta[:ub](n)
        for _ in 1:5
            x = lb .+ (ub .- lb) .* rand(n)
            programmed_grad = dejongf4_gradient(x; noise=0.0)
            ad_grad = ForwardDiff.gradient(x -> dejongf4(x; noise=0.0), x)
            @test isapprox(programmed_grad, ad_grad, atol=1e-3)
        end
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError dejongf4(Float64[])
        @test isnan(dejongf4([NaN, 0.0]; noise=0.0))
        @test isnan(dejongf4([0.0, NaN]; noise=0.0))
        @test isinf(dejongf4([Inf, 0.0]; noise=0.0))
        @test isinf(dejongf4([0.0, Inf]; noise=0.0))
        @test isfinite(dejongf4([1e-308, 1e-308]; noise=0.0))
    end
end