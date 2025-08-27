# test/sineenvelope_tests.jl
# Purpose: Tests for the Sine Envelope function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SINEENVELOPE_FUNCTION, sineenvelope

@testset "SineEnvelope Tests" begin
    tf = SINEENVELOPE_FUNCTION

    # Edge Cases
    @test_throws ArgumentError sineenvelope(Float64[])
    @test isnan(sineenvelope(fill(NaN, 2)))
    @test isinf(sineenvelope(fill(Inf, 2)))
    @test isfinite(sineenvelope(fill(1e-308, 2)))

    # Function Values
    @test sineenvelope(tf.meta[:min_position]()) ≈ -1.0 atol=1e-6
    @test sineenvelope(tf.meta[:start]()) ≈ -0.026215469198405728 atol=1e-6

    # Metadata
    @test tf.meta[:name] == "sineenvelope"
    @test tf.meta[:start]() == [1.0, 1.0]
    @test tf.meta[:min_position]() == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ -1.0 atol=1e-6
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])

    # Optimization Tests
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        start = tf.meta[:min_position]() + 0.01 * randn(2)
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-6, iterations=1000))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end
end