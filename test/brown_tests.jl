# test/brown_tests.jl
# Purpose: Tests for the Brown test function.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 01 September 2025

using Test
using NonlinearOptimizationTestFunctions: BROWN_FUNCTION, brown
using Optim

@testset "Brown Tests" begin
    tf = BROWN_FUNCTION
    n = 2

    # Test Funktionswerte
    @test brown(zeros(n)) ≈ 0.0 atol=1e-6  # Minimum bei (0, 0)
    @test brown([1.0, 1.0]) ≈ 2.0 atol=1e-6  # Manuell berechnet: (1^2)^(1^2+1) + (1^2)^(1^2+1) = 1^2 + 1^2 = 2

    # Test Metadaten
    @test tf.meta[:name] == "brown"
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:start](n) == ones(n)
    @test tf.meta[:lb](n) == fill(-1.0, n)
    @test tf.meta[:ub](n) == fill(4.0, n)
    @test tf.meta[:properties] == Set(["unimodal", "non-separable", "differentiable", "scalable", "continuous", "bounded"])
    @test tf.meta[:in_molga_smutnicki_2005] == false

    # Test Edge Cases
    @test_throws ArgumentError brown(Float64[])
    @test_throws ArgumentError brown([1.0])
    @test isnan(brown([NaN, 1.0]))
    @test isinf(brown([Inf, 1.0]))
    @test isfinite(brown([-1.0, -1.0]))
    @test isfinite(brown([4.0, 4.0]))

    # Test Optimierung mit Optim.jl (unbeschränkt)
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ 0.0 atol=1e-6
    @test Optim.minimizer(result) ≈ zeros(n) atol=1e-6

    # Test mit Fminbox für Schranken
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](n), tf.meta[:ub](n), tf.meta[:start](n), Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ 0.0 atol=1e-6
    @test Optim.minimizer(result) ≈ zeros(n) atol=1e-6
    @test all(tf.meta[:lb](n) .<= Optim.minimizer(result) .<= tf.meta[:ub](n))
end