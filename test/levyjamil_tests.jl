# test/levyjamil_tests.jl
# Purpose: Tests for the Levy function (Jamil & Yang, 2013).
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 27, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: LEVYJAMILFUNCTION, levyjamil

@testset "Levy Jamil Tests" begin
    tf = LEVYJAMILFUNCTION
    n = 2  # Standard dimension
    @test_throws ArgumentError levyjamil(Float64[])
    @test isnan(levyjamil(fill(NaN, n)))
    @test isinf(levyjamil(fill(Inf, n)))
    @test isfinite(levyjamil(fill(1e-308, n)))
    @test levyjamil(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test levyjamil(tf.meta[:start](n)) ≈ 2.0 atol=1e-6  # f(0,0) = 2.0
    @test tf.meta[:name] == "levyjamil"
    @test tf.meta[:start](n) == zeros(n)
    @test tf.meta[:min_position](n) == [1.0, 1.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "scalable", "multimodal", "bounded", "continuous"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Perturbed start due to multimodality
        result = optimize(
            tf.f,
            tf.gradient!,
            tf.meta[:lb](n),
            tf.meta[:ub](n),
            start,
            Fminbox(LBFGS()),
            Optim.Options(f_reltol=1e-6, g_tol=1e-8, iterations=10000, time_limit=120.0)
        )
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test norm(Optim.minimizer(result) - tf.meta[:min_position](n)) < 1e-3
    end
end