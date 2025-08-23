# test/shekel_tests.jl
# Purpose: Tests for the Shekel function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 22, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: SHEKEL_FUNCTION, shekel

@testset "Shekel Tests" begin
    tf = SHEKEL_FUNCTION
    n = 4  # Shekel ist nur für n=4 definiert
    @test_throws ArgumentError shekel(Float64[])
    @test isnan(shekel(fill(NaN, n)))
    @test isfinite(shekel(tf.meta[:lb](n)))  # Prüft untere Bounds
    @test isfinite(shekel(tf.meta[:ub](n)))  # Prüft obere Bounds
    @test isfinite(shekel(fill(1e-308, n)))
    @test shekel(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-8
    @test shekel(tf.meta[:start](n)) ≈ -0.46329209926592196 atol=1e-6
    @test tf.meta[:name] == "shekel"
    @test tf.meta[:start](n) == [2.0, 2.0, 2.0, 2.0]
    @test tf.meta[:min_position](n) ≈ [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956] atol=1e-8
    @test tf.meta[:min_value] ≈ -10.536409825004505 atol=1e-8
    @test tf.meta[:lb](n) == [0.0, 0.0, 0.0, 0.0]
    @test tf.meta[:ub](n) == [10.0, 10.0, 10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "finite_at_inf"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Start nahe Minimum für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-8
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=0.02  # Toleranz bleibt für Robustheit
    end
end