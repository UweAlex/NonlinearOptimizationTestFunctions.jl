# test/ackley2_tests.jl
# Purpose: Tests for the Ackley2 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 25, 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: ACKLEY2_FUNCTION, ackley2

@testset "Ackley2 Tests" begin
    tf = ACKLEY2_FUNCTION
    n = 2  # Ackley2 ist auf n=2 festgelegt
    Random.seed!(1234)  # Für reproduzierbare Störung

    # Edge Cases
    @test_throws ArgumentError ackley2(Float64[])
    @test_throws ArgumentError ackley2([1.0, 2.0, 3.0])
    @test isnan(ackley2([NaN, 0.0]))
    @test isinf(ackley2([Inf, 0.0]))
    @test isfinite(ackley2([1e-308, 1e-308]))

    # Metadaten
    @test tf.meta[:name] == "ackley2"
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ -200.0 atol=1e-6
    @test tf.meta[:lb]() == [-32.0, -32.0]
    @test tf.meta[:ub]() == [32.0, 32.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["unimodal", "non-convex", "non-separable", "partially differentiable", "continuous", "bounded"])

    # Funktionswerte
    start = [1.0, 1.0]  # Typischer Startpunkt
    min_pos = tf.meta[:min_position]()
    min_val = tf.meta[:min_value]
    @test ackley2(min_pos) ≈ min_val atol=1e-6  # Wert am globalen Minimum
    @test ackley2(start) ≈ -194.42239680657946 atol=1e-6  # Wert bei [1, 1], korrigiert

    # Gradient am Minimum
    grad = zeros(n)
    tf.gradient!(grad, min_pos)
    @test grad ≈ zeros(n) atol=0.01  # Gradient am Minimum

    # Optimierungstests
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        start = [1.0, 1.0] + 0.01 * randn(2)  # Perturbierter Startpunkt
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ min_val atol=1e-4
        @test Optim.minimizer(result) ≈ min_pos atol=1e-3
    end
end