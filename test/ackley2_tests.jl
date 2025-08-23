# test/ackley2_tests.jl
# Purpose: Tests for the Ackley2 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 23, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: ACKLEY2_FUNCTION, ackley2

@testset "Ackley2 Tests" begin
    tf = ACKLEY2_FUNCTION
    n = 2  # Ackley2 ist auf n=2 festgelegt

    # Edge Cases
    @test_throws ArgumentError ackley2(Float64[])
    @test_throws ArgumentError ackley2([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(ackley2([NaN, 0.0]))
    @test isinf(ackley2([Inf, 0.0]))
    @test isfinite(ackley2([1e-308, 1e-308]))

    # Funktionswerte
    @test ackley2(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test ackley2(tf.meta[:start](n)) ≈ -200.0 atol=1e-6  # Wert am Startpunkt [0.0, 0.0]

    # Metadaten
    @test tf.meta[:name] == "ackley2"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ -200.0 atol=1e-6
    @test tf.meta[:lb](n) == [-32.0, -32.0]
    @test tf.meta[:ub](n) == [32.0, 32.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["unimodal", "non-convex", "non-separable", "differentiable", "continuous", "bounded"])

    # Optimierungstests
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end