# test/levy_tests.jl
# Purpose: Tests for the Levy function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: LEVY_FUNCTION, levy

@testset "Levy Tests" begin
    tf = LEVY_FUNCTION
    n = 2  # Standard dimension
    @test_throws ArgumentError levy(Float64[])
    @test isnan(levy(fill(NaN, n)))
    @test isinf(levy(fill(Inf, n)))
    @test isfinite(levy(fill(1e-308, n)))
    @test levy(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test levy(tf.meta[:start](n)) ≈ 0.0 atol=1e-6
    @test tf.meta[:name] == "levy"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [1.0, 1.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "scalable", "multimodal"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Perturbed start due to multimodality
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end