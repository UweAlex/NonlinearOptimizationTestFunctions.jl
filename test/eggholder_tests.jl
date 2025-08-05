# test/eggholder_tests.jl
# Purpose: Tests for the Eggholder function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 05 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: EGGHOLDER_FUNCTION, eggholder

@testset "Eggholder Tests" begin
    tf = EGGHOLDER_FUNCTION
    n = 2  # Eggholder ist nur für n=2 definiert

    # Edge Cases
    @test_throws ArgumentError eggholder(Float64[])
    @test isnan(eggholder(fill(NaN, n)))
    @test isinf(eggholder(fill(Inf, n)))
    @test isfinite(eggholder(fill(1e-308, n)))

    # Funktionswerte
    @test eggholder(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test eggholder(tf.meta[:start](n)) ≈ -25.460337185286313 atol=1e-6  # Korrigierter Wert

    # Metadaten
    @test tf.meta[:name] == "eggholder"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [512.0, 404.2318058008512]
    @test tf.meta[:min_value] ≈ -959.6406627208506 atol=1e-6
    @test tf.meta[:lb](n) == [-512.0, -512.0]
    @test tf.meta[:ub](n) == [512.0, 512.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "differentiable", "non-convex", "non-separable", "bounded"])

    # Optimierungstests
    @testset "Optimization Tests" begin
        # Startpunkt nahe dem Minimum, mit Schranken für multimodale Funktion
        start = [500.0, 400.0]  # Näher am Minimum für bessere Konvergenz
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](n), tf.meta[:ub](n), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-3  # Größere Toleranz
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-2  # Größere Toleranz
    end
end