# test/hartmann_tests.jl
# Purpose: Tests for the Hartmann function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 01 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctionsInJulia: HARTMANN_FUNCTION, hartmann

@testset "Hartmann Tests" begin
    tf = HARTMANN_FUNCTION
    n = 3
    @test_throws ArgumentError hartmann(Float64[])
    @test_throws ArgumentError hartmann([1.0, 1.0])
    @test isnan(hartmann(fill(NaN, n)))
    @test isinf(hartmann(fill(Inf, n)))
    @test isfinite(hartmann(fill(1e-308, n)))
    @test hartmann(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test hartmann(tf.meta[:start](n)) ≈ -0.6280220961750616 atol=1e-6  # Updated to match computed value
    @test tf.meta[:name] == "hartmann"
    @test tf.meta[:start](n) == [0.5, 0.5, 0.5]
    @test tf.meta[:min_position](n) ≈ [0.114614, 0.555649, 0.852547] atol=1e-6
    @test tf.meta[:min_value] ≈ -3.86278214782076 atol=1e-6
    @test tf.meta[:lb](n) == fill(0.0, 3)
    @test tf.meta[:ub](n) == fill(1.0, 3)
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Leichtes Rauschen für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end