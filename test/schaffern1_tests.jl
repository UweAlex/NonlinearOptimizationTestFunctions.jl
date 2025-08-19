# test/schaffern1_tests.jl
# Purpose: Tests for the SchafferN1 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 18 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SCHAFFERN1_FUNCTION, schaffern1

@testset "SchafferN1 Tests" begin
    tf = SCHAFFERN1_FUNCTION
    n = 2

    # Edge Cases
    @test_throws ArgumentError schaffern1(Float64[])
    @test_throws ArgumentError schaffern1([1.0, 2.0, 3.0])
    @test isnan(schaffern1(fill(NaN, n)))
    @test schaffern1(fill(Inf, n)) ≈ 0.5 # Denominator grows faster, so fraction -> 0
    @test isfinite(schaffern1(fill(1e-308, n)))

    # Function Values
    @test schaffern1(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test schaffern1(tf.meta[:start](n)) ≈ 0.9737845 atol=1e-5 # Corrected expected value

    # Metadata
    @test tf.meta[:name] == "schaffern1"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-100.0, -100.0]
    @test tf.meta[:ub](n) == [100.0, 100.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"])

    # Optimization Test
    @testset "Optimization Test" begin
        Random.seed!(123)
        # Start near the minimum to ensure convergence for this highly multimodal function
        start = tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-8))
        
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end