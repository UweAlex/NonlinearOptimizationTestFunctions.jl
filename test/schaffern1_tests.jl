# test/schaffern1_tests.jl
# Purpose: Tests for the Schaffer N1 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SCHAFFERN1_FUNCTION, schaffern1

@testset "SchafferN1 Tests" begin
    tf = SCHAFFERN1_FUNCTION

    # Edge Cases
    @test_throws ArgumentError schaffern1(Float64[])
    @test_throws ArgumentError schaffern1([1.0, 2.0, 3.0])
    @test isnan(schaffern1(fill(NaN, 2)))
    @test schaffern1(fill(Inf, 2)) ≈ 0.5  # Denominator grows faster, so fraction -> 0
    @test isfinite(schaffern1(fill(1e-308, 2)))

    # Function Values
    @test schaffern1(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-6
    @test schaffern1(tf.meta[:start]()) ≈ 0.9737845 atol=1e-5  # f([1.0, 1.0])

    # Metadata
    @test tf.meta[:name] == "schaffern1"
    @test tf.meta[:start]() == [1.0, 1.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded", "continuous"])

    # Optimization Test
    @testset "Optimization Test" begin
        Random.seed!(123)
        # Start near the minimum to ensure convergence for this highly multimodal function
        start = tf.meta[:min_position]() + 0.01 * randn(2)
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-8, g_tol=1e-8, iterations=1000))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end
end