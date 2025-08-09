# test/step_tests.jl
# Purpose: Tests for the De Jong F3 (Step) function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 09 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: STEP_FUNCTION, step

@testset "Step Tests" begin
    tf = STEP_FUNCTION
    n = 2  # Standarddimension
    n_high = 10  # Höhere Dimension für Skalierbarkeit

    # Edge Cases
    @test_throws ArgumentError step(Float64[])
    @test isnan(step(fill(NaN, n)))
    @test isinf(step(fill(Inf, n)))
    @test isfinite(step(fill(1e-308, n)))

    # Funktionswerte
    @test step(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test step(tf.meta[:start](n)) ≈ 0.0 atol=1e-6  # Startpunkt (0, 0) ergibt f(0, 0) = 0
    @test step([0.4, 0.4]) ≈ 0.0 atol=1e-6  # Innerhalb [-0.5, 0.5]^n ist f(x) = 0
    @test step([1.0, 1.0]) ≈ 2.0 atol=1e-6  # f([1, 1]) = floor(1 + 0.5)^2 + floor(1 + 0.5)^2 = 1^2 + 1^2 = 2

    # Metadaten
    @test tf.meta[:name] == "step"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-5.12, -5.12]
    @test tf.meta[:ub](n) == [5.12, 5.12]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"])

    # Skalierbarkeit: Tests für n=10
    @test step(tf.meta[:min_position](n_high)) ≈ tf.meta[:min_value] atol=1e-6
    @test step(tf.meta[:start](n_high)) ≈ 0.0 atol=1e-6
    @test length(tf.meta[:start](n_high)) == n_high
    @test length(tf.meta[:min_position](n_high)) == n_high
    @test length(tf.meta[:lb](n_high)) == n_high
    @test length(tf.meta[:ub](n_high)) == n_high

    # Optimierungstests
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3

        # Test für höhere Dimension (n=10)
        start_high = tf.meta[:start](n_high)
        result_high = optimize(tf.f, tf.gradient!, start_high, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result_high) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result_high) ≈ tf.meta[:min_position](n_high) atol=1e-3
    end

    # Edge Case: Falsche Dimension
    @test_throws ArgumentError tf.meta[:start](0)
    @test_throws ArgumentError tf.meta[:min_position](0)
    @test_throws ArgumentError tf.meta[:lb](0)
    @test_throws ArgumentError tf.meta[:ub](0)
end