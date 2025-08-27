# test/wood_tests.jl
# Purpose: Tests for the Wood function in NonlinearOptimizationTestFunctions.
# Context: Part of the test suite, verifies function values, metadata, edge cases, and optimization.
# Last modified: 27 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim, Random
using NonlinearOptimizationTestFunctions: WOOD_FUNCTION, wood

@testset "Wood Tests" begin
    tf = WOOD_FUNCTION
    start = tf.meta[:start]()
    min_pos = tf.meta[:min_position]()
    min_value = tf.meta[:min_value]

    # Test Funktionswerte
    @test wood(start) ≈ 42.0 atol=1e-6  # 100(0^2-0)^2 + (0-1)^2 + (0-1)^2 + 90(0^2-0)^2 + 10.1((0-1)^2 + (0-1)^2) + 19.8(0-1)(0-1) = 42.0
    @test wood(min_pos) ≈ min_value atol=1e-6  # min_pos = [1, 1, 1, 1], min_value = 0

    # Test Edge Cases
    @test_throws ArgumentError wood(Float64[])
    @test_throws ArgumentError wood([0.0, 0.0, 0.0])
    @test isnan(wood(fill(NaN, 4)))
    @test isinf(wood(fill(Inf, 4)))
    @test isfinite(wood(fill(1e-308, 4)))
    @test isfinite(wood(tf.meta[:lb]()))
    @test isfinite(wood(tf.meta[:ub]()))

    # Test Optimierung
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start + 0.01 * randn(4), Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=1000))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ min_value atol=1e-6
        @test Optim.minimizer(result) ≈ min_pos atol=1e-3
    end

    # Test Metadaten
    @test tf.meta[:name] == "wood"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    @test tf.meta[:lb]() == [-10.0, -10.0, -10.0, -10.0]
    @test tf.meta[:ub]() == [10.0, 10.0, 10.0, 10.0]
end