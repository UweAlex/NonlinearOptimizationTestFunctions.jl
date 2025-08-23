# test/bartelsconn_tests.jl
# Purpose: Tests for the Bartels Conn function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 23, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: BARTELS_CONN_FUNCTION, bartelsconn

@testset "Bartels Conn Tests" begin
    tf = BARTELS_CONN_FUNCTION
    n = 2  # Bartels Conn ist auf n=2 festgelegt

    # Edge Cases
    @test_throws ArgumentError bartelsconn(Float64[])
    @test_throws ArgumentError bartelsconn([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(bartelsconn([NaN, 0.0]))
    @test isinf(bartelsconn([Inf, 0.0]))
    @test isfinite(bartelsconn([1e-308, 1e-308]))

    # Funktionswerte
    @test bartelsconn(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test bartelsconn(tf.meta[:start](n)) ≈ 1.0 atol=1e-6  # Wert am Startpunkt [0.0, 0.0]

    # Metadaten
    @test tf.meta[:name] == "bartelsconn"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ 1.0 atol=1e-6
    @test tf.meta[:lb](n) == [-500.0, -500.0]
    @test tf.meta[:ub](n) == [500.0, 500.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "continuous", "bounded"])

    # Optimierungstests
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n) + 0.01 * randn(n)  # Leichte Störung für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end