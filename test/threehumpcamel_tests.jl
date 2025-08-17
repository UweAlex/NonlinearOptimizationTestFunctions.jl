# test/threehumpcamel_tests.jl
# Purpose: Tests for the ThreeHumpCamel function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 17, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: THREEHUMPCAMEL_FUNCTION, threehumpcamel

@testset "ThreeHumpCamel Tests" begin
    tf = THREEHUMPCAMEL_FUNCTION
    n = 2  # z.B. 2 für fixe Dimensionen, 1 oder variabel für skalierbare

    # Edge Cases
    @test_throws ArgumentError threehumpcamel(Float64[])
    @test isnan(threehumpcamel(fill(NaN, n)))
    @test isinf(threehumpcamel(fill(Inf, n)))  # Oder isnan, je nach Funktion
    @test isfinite(threehumpcamel(fill(1e-308, n)))

    # Funktionswerte
    @test threehumpcamel(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test threehumpcamel(tf.meta[:start](n)) ≈ 9.866666666666667 atol=1e-6  # Durch Berechnung ermitteln

    # Metadaten
    @test tf.meta[:name] == "threehumpcamel"
    @test tf.meta[:start](n) == [2.0, 2.0]
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-5.0, -5.0]
    @test tf.meta[:ub](n) == [5.0, 5.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])

    # Optimierungstests
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)  # Oder perturbed für multimodale: tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end

    # Optionale Tests für skalierbare Funktionen
    # @testset "Scalability Tests" begin
    #     n_high = 10
    #     @test <functionname>(tf.meta[:min_position](n_high)) ≈ tf.meta[:min_value] atol=1e-6
    #     result_high = optimize(tf.f, tf.gradient!, tf.meta[:start](n_high), LBFGS(), Optim.Options(f_reltol=1e-6))
    #     @test Optim.minimum(result_high) ≈ tf.meta[:min_value] atol=1e-5
    #     @test Optim.minimizer(result_high) ≈ tf.meta[:min_position](n_high) atol=1e-3
    # end
end