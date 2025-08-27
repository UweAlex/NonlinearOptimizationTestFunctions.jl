# test/threehumpcamel_tests.jl
# Purpose: Tests for the Three-Hump Camel function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: THREEHUMPCAMEL_FUNCTION, threehumpcamel

@testset "ThreeHumpCamel Tests" begin
    tf = THREEHUMPCAMEL_FUNCTION

    # Edge Cases
    @test_throws ArgumentError threehumpcamel(Float64[])
    @test isnan(threehumpcamel(fill(NaN, 2)))
    @test isinf(threehumpcamel(fill(Inf, 2)))
    @test isfinite(threehumpcamel(fill(1e-308, 2)))

    # Function Values
    @test threehumpcamel(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-6
    @test threehumpcamel(tf.meta[:start]()) ≈ 9.866666666666667 atol=1e-6

    # Metadata
    @test tf.meta[:name] == "threehumpcamel"
    @test tf.meta[:start]() == [2.0, 2.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb]() == [-5.0, -5.0]
    @test tf.meta[:ub]() == [5.0, 5.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])

    # Optimization Tests
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        start = tf.meta[:min_position]() + 0.01 * randn(2)  # Perturbed for multimodality
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=1000))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end
end