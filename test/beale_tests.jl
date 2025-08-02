# test/beale_tests.jl
# Purpose: Tests for the Beale function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: BEALE_FUNCTION, beale

@testset "Beale Tests" begin
    tf = BEALE_FUNCTION
    n = 2  # Fixed dimension
    @test_throws ArgumentError beale(Float64[])
    @test_throws ArgumentError beale([1.0, 1.0, 1.0])
    @test isnan(beale([NaN, 1.0]))
    @test isinf(beale([Inf, 1.0]))
    @test isfinite(beale([1e-308, 1e-308]))
    @test beale(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test beale(tf.meta[:start](n)) ≈ 14.203125 atol=1e-6
    @test tf.meta[:name] == "beale"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [3.0, 0.5]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-4.5, -4.5]
    @test tf.meta[:ub](n) == [4.5, 4.5]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "multimodal"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Perturbed start due to multimodality
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end