# test/styblinskitang_tests.jl
# Purpose: Tests for the Styblinski-Tang function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: STYBLINSKITANG_FUNCTION, styblinskitang

@testset "Styblinski-Tang Tests" begin
    tf = STYBLINSKITANG_FUNCTION
    n = 2  # Standard dimension
    @test_throws ArgumentError styblinskitang(Float64[])
    @test isnan(styblinskitang(fill(NaN, n)))
    @test isinf(styblinskitang(fill(Inf, n)))
    @test isfinite(styblinskitang(fill(1e-308, n)))
    @test styblinskitang(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol=1e-5
    @test styblinskitang(tf.meta[:start](n)) ≈ -10.0 atol=1e-6
    @test tf.meta[:name] == "styblinskitang"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) ≈ [-2.903534, -2.903534] atol=1e-6
    @test tf.meta[:min_value](n) ≈ -39.166165 * n atol=1e-6
    @test tf.meta[:lb](n) == [-5.0, -5.0]
    @test tf.meta[:ub](n) == [5.0, 5.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "scalable", "multimodal"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Perturbed start due to multimodality
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value](n) atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end