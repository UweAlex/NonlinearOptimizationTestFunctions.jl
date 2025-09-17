# test/beale_tests.jl
# Purpose: Tests for the Beale function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 25, 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: BEALE_FUNCTION, beale

@testset "Beale Tests" begin
    tf = BEALE_FUNCTION
    n = 2  # Beale ist auf n=2 festgelegt
    Random.seed!(1234)  # Für reproduzierbare Störung

    # Edge Cases
    @test_throws ArgumentError beale(Float64[])
    @test_throws ArgumentError beale([1.0, 1.0, 1.0])
    @test isnan(beale([NaN, 1.0]))
    @test isinf(beale([Inf, 1.0]))
    @test isfinite(beale([1e-308, 1e-308]))

    # Funktionswerte
    @test beale(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
    @test beale(tf.meta[:start]()) ≈ 14.203125 atol=1e-6  # Wert am Startpunkt [1.0, 1.0]

    # Metadaten
    @test tf.meta[:name] == "beale"
    @test tf.meta[:start]() == [1.0, 1.0]
    @test tf.meta[:min_position]() ≈ [3.0, 0.5] atol=1e-6
    @test tf.meta[:min_value]() ≈ 0.0 atol=1e-6
    @test tf.meta[:lb]() == [-4.5, -4.5]
    @test tf.meta[:ub]() == [4.5, 4.5]
    @test tf.meta[:in_molga_smutnicki_2005] == true  # Korrigiert: Beale ist in Molga & Smutnicki (2005)
    @test Set(tf.meta[:properties]) == Set(["unimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])

    # Optimierungstests mit Schranken (verwende LBFGS, da differenzierbar)
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        start = [1.0, 1.0]  # Deterministischer Startpunkt
        result = optimize(tf.f, lb, ub, start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ 0.0 atol=1e-5
        @test Optim.minimizer(result) ≈ [3.0, 0.5] atol=1e-3
    end
end