# test/mccormick_tests.jl
# Purpose: Tests for the McCormick function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 02 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: MCCORMICK_FUNCTION, mccormick

@testset "McCormick Tests" begin
    tf = MCCORMICK_FUNCTION
    n = 2  # Fixed dimension
    @test_throws ArgumentError mccormick(Float64[])
    @test_throws ArgumentError mccormick([0.0, 0.0, 0.0])
    @test isnan(mccormick([NaN, 0.0]))
    @test isinf(mccormick([Inf, 0.0]))
    @test isfinite(mccormick([1e-308, 1e-308]))
    @test mccormick(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test mccormick(tf.meta[:start](n)) ≈ 1.0 atol=1e-6
    @test tf.meta[:name] == "mccormick"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) ≈ [-0.547197553, -1.547197553] atol=1e-6
    @test tf.meta[:min_value] ≈ -1.913222954981037 atol=1e-6
    @test tf.meta[:lb](n) == [-1.5, -3.0]
    @test tf.meta[:ub](n) == [4.0, 4.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "multimodal"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Perturbed start due to multimodality
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end