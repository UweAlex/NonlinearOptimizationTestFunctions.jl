# test/trid_tests.jl
# Purpose: Tests for the Trid function in NonlinearOptimizationTestFunctions.
# Context: Part of the test suite, verifies function values, metadata, edge cases, and optimization.
# Last modified: 27 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim, Random
using NonlinearOptimizationTestFunctions: TRID_FUNCTION, trid

@testset "Trid Tests" begin
    tf = TRID_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    min_value = tf.meta[:min_value](n)

    # Test Funktionswerte
    @test trid(start) ≈ 2.0 atol=1e-6  # Manuelle Berechnung: (0-1)^2 + (0-1)^2 = 2
    @test trid(min_pos) ≈ min_value atol=1e-6  # min_pos = [1, 1], min_value = -2

    # Test Edge Cases
    @test_throws ArgumentError trid(Float64[])
    @test_throws ArgumentError trid([0.0])
    @test isnan(trid(fill(NaN, n)))
    @test isinf(trid(fill(Inf, n)))
    @test isfinite(trid(fill(1e-308, n)))
    @test isfinite(trid(tf.meta[:lb](n)))
    @test isfinite(trid(tf.meta[:ub](n)))

    # Test Metadaten
    @test tf.meta[:name] == "trid"
    @test tf.meta[:properties] == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable", "bounded", "continuous"])
    @test tf.meta[:lb](n) == [-4, -4]
    @test tf.meta[:ub](n) == [4, 4]

    # Test Optimierung
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        result = optimize(tf.f, tf.gradient!, float.(tf.meta[:lb](n)), float.(tf.meta[:ub](n)), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=1000))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ min_value atol=1e-6
        @test Optim.minimizer(result) ≈ min_pos atol=1e-3
    end
end