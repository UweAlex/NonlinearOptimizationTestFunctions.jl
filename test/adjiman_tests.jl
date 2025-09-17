# test/adjiman_tests.jl
# Purpose: Tests for the Adjiman function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 25, 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: ADJIMAN_FUNCTION, adjiman

@testset "Adjiman Tests" begin
    tf = ADJIMAN_FUNCTION
    n = 2  # Adjiman ist auf n=2 festgelegt
    Random.seed!(1234)  # Für reproduzierbare Störung

    # Edge Cases
    @test_throws ArgumentError adjiman(Float64[])
    @test_throws ArgumentError adjiman([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(adjiman([NaN, 0.0]))
    @test isinf(adjiman([Inf, 0.0]))
    @test isfinite(adjiman([1e-308, 1e-308]))

    # Funktionswerte
    @test adjiman(tf.meta[:min_position]()) ≈ -2.021806783359787 atol=1e-6  # Zeile 22
    @test adjiman(tf.meta[:start]()) ≈ 0.0 atol=1e-6  # Zeile 23, Wert am Startpunkt [0.0, 0.0]

    # Metadaten
    @test tf.meta[:name] == "adjiman"
    @test tf.meta[:start]() == [0.0, 0.0]  # Zeile 27
    @test tf.meta[:min_position]() ≈ [2.0, 0.10578347] atol=1e-6  # Zeile 28
    @test isapprox(tf.meta[:min_value](), -2.021806783359787, atol=1e-6)
    @test tf.meta[:lb]() == [-1.0, -1.0]  # Zeile 30
    @test tf.meta[:ub]() == [2.0, 1.0]  # Zeile 31
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "continuous", "bounded"])

    # Optimierungstests mit Schranken
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()  # Zeile 36
        ub = tf.meta[:ub]()
        start = tf.meta[:start]() + 0.01 * randn(n)  # Leichte Störung für multimodale Funktion
        inner_optimizer = LBFGS()
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(inner_optimizer), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ -2.021806783359787 atol=1e-5
        @test Optim.minimizer(result) ≈ [2.0, 0.10578347] atol=1e-3
    end
end