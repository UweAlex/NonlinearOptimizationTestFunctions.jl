# test/crossintray_tests.jl
# Purpose: Tests for the Cross-in-Tray function in NonlinearOptimizationTestFunctions.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 25 August 2025

using Test
using Optim
using ForwardDiff
using NonlinearOptimizationTestFunctions: CROSSINTRAY_FUNCTION, crossintray, crossintray_gradient

@testset "Cross-in-Tray Tests" begin
    tf = CROSSINTRAY_FUNCTION
    n = 2  # Fixed dimension for Cross-in-Tray

    # Metadata tests
    @test tf.meta[:name] == "crossintray"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "partially differentiable", "bounded", "continuous"])

    # Function value tests
    start = tf.meta[:start]()
    @test crossintray(start) ≈ -0.0001 atol=1e-6  # Value at [0.0, 0.0]
    min_pos = tf.meta[:min_position]()
    @test crossintray(min_pos) ≈ tf.meta[:min_value]() atol=1e-6
    @test start == [0.0, 0.0]
    @test min_pos ≈ [1.349406575769872, 1.349406575769872] atol=1e-6
    @test tf.meta[:min_value]() ≈ -2.062611870822739 atol=1e-6
    @test tf.meta[:lb]() == [-10.0, -10.0]
    @test tf.meta[:ub]() == [10.0, 10.0]

    # Gradient at minimum
    grad = crossintray_gradient(min_pos)
    @test ≈(grad, zeros(n), atol=1e-6)

    # Edge cases
    @test_throws ArgumentError crossintray(Float64[])
    @test_throws ArgumentError crossintray([0.0, 0.0, 0.0])
    @test isnan(crossintray([NaN, 0.0]))
    @test isnan(crossintray([0.0, NaN]))
    @test isinf(crossintray([Inf, 0.0]))
    @test isinf(crossintray([0.0, Inf]))
    @test isfinite(crossintray([1e-308, 1e-308]))

   
    # Gradient comparison tests
    @testset "Gradient Comparison Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        for _ in 1:5
            x = lb .+ (ub .- lb) .* rand(n)
            programmed_grad = crossintray_gradient(x)
            ad_grad = ForwardDiff.gradient(crossintray, x)
            @test ≈(programmed_grad, ad_grad, atol=1e-2)
        end
    end
end