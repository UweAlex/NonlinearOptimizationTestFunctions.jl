# test/branin_tests.jl
# Purpose: Tests for the Branin function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 18. Juli 2025

using Test, Optim
using NonlinearOptimizationTestFunctionsInJulia: BRANIN_FUNCTION, branin

@testset "Branin Tests" begin
    tf = BRANIN_FUNCTION
    n = 2
    @test_throws ArgumentError branin(Float64[])
    @test_throws ArgumentError branin([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(branin([NaN, 0.0]))
    @test isinf(branin([Inf, 0.0]))
    @test isfinite(branin([1e-308, 1e-308]))
    @test branin(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test branin(tf.meta[:start](n)) ≈ 55.602112642270262 atol=1e-6  # Korrigierter Wert
    @test tf.meta[:name] == "branin"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [-π, 12.275]
    @test tf.meta[:min_value] ≈ 0.397887 atol=1e-6
    @test tf.meta[:lb](n) == [-5.0, 0.0]
    @test tf.meta[:ub](n) == [10.0, 15.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "differentiable", "non-convex", "non-separable", "bounded"])
    @testset "Optimization Tests" begin
        # Startpunkt leicht vom Minimum entfernt, da multimodal
        start = tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        # Prüfe, ob das gefundene Minimum einem der drei globalen Minima nahe ist
        minimizer = Optim.minimizer(result)
        minima = [[-π, 12.275], [π, 2.275], [9.424778, 2.475]]
        @test any(norm(minimizer - m) < 1e-3 for m in minima)
    end
end