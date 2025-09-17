# test/bartelsconn_tests.jl
# Purpose: Tests for the BartelsConn function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 25, 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: BARTELSCONN_FUNCTION, bartelsconn

@testset "BartelsConn Tests" begin
    tf = BARTELSCONN_FUNCTION
    n = 2  # BartelsConn ist auf n=2 festgelegt
    Random.seed!(1234)  # Für reproduzierbare Störung

    # Edge Cases
    @test_throws ArgumentError bartelsconn(Float64[])
    @test_throws ArgumentError bartelsconn([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(bartelsconn([NaN, 0.0]))
    @test isinf(bartelsconn([Inf, 0.0]))
    @test isfinite(bartelsconn([1e-308, 1e-308]))

    # Funktionswerte
    @test bartelsconn(tf.meta[:min_position]()) ≈ 1.0 atol=1e-6
    @test bartelsconn(tf.meta[:start]()) ≈ 1.0 atol=1e-6  # Wert am Startpunkt [0.0, 0.0]

    # Metadaten
    @test tf.meta[:name] == "bartelsconn"
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value]() ≈ 1.0 atol=1e-6
    @test tf.meta[:lb]() == [-500.0, -500.0]
    @test tf.meta[:ub]() == [500.0, 500.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "partially differentiable", "bounded", "continuous"])

    # Subgradienten-Test
    @test_throws DomainError bartelsconn_gradient([0.0, 0.0])  # Nicht differenzierbar am Minimum

    # Optimierungstests mit Schranken (verwende NelderMead, da nicht-differenzierbar)
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        start = tf.meta[:start]() + 0.01 * randn(n)  # Leichte Störung
        result = optimize(tf.f, lb, ub, start, Fminbox(NelderMead()), Optim.Options(f_reltol=1e-6))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ 1.0 atol=1e-5
        @test Optim.minimizer(result) ≈ [0.0, 0.0] atol=1e-3
    end
end