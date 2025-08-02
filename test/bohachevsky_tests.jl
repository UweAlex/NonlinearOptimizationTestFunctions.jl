# test/bohachevsky_tests.jl
# Purpose: Tests for the Bohachevsky function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: BOHACHEVSKY_FUNCTION, bohachevsky

@testset "Bohachevsky Tests" begin
    tf = BOHACHEVSKY_FUNCTION
    n = 2  # Standarddimension
    @test_throws ArgumentError bohachevsky(Float64[])
    @test_throws ArgumentError bohachevsky([1.0])  # Mindestens 2 Dimensionen
    @test isnan(bohachevsky(fill(NaN, n)))
    @test isinf(bohachevsky(fill(Inf, n)))
    @test isfinite(bohachevsky(fill(1e-308, n)))
    @test bohachevsky(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test bohachevsky(tf.meta[:start](n)) ≈ 3.6 atol=1e-6
    @test tf.meta[:name] == "bohachevsky"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "scalable"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Leicht gestörter Startpunkt, da multimodal
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end