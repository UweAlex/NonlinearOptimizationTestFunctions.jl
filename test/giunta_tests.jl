# test/giunta_tests.jl
# Purpose: Tests for the Giunta function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using NonlinearOptimizationTestFunctions: GIUNTA_FUNCTION, giunta

@testset "Giunta Function Tests" begin
    tf = GIUNTA_FUNCTION
    n = 2  # Giunta ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "giunta"

        @test isfinite(giunta(tf.meta[:lb]()))
        @test isfinite(giunta(tf.meta[:ub]()))
        @test isfinite(giunta(fill(1e-308, n)))
        @test isinf(giunta(fill(Inf, n)))
        @test giunta(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
        @test giunta(tf.meta[:start]()) ≈ 0.363477 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [0.46732002530945826, 0.46732002530945826] atol=1e-6
        @test tf.meta[:min_value]() ≈ 0.06447042053690566 atol=1e-6
        @test tf.meta[:lb]() == [-1.0, -1.0]
        @test tf.meta[:ub]() == [1.0, 1.0]
        @test tf.meta[:properties] == Set(["multimodal", "non-convex", "separable", "differentiable", "bounded", "continuous"])
    end

   
   

    @testset "Edge Cases" begin
        @test_throws ArgumentError giunta(Float64[])
        @test_throws ArgumentError giunta([1.0])
        @test_throws ArgumentError giunta([1.0, 2.0, 3.0])
        @test isnan(giunta(fill(NaN, n)))
        @test isinf(giunta(fill(Inf, n)))
        @test isfinite(giunta(fill(1e-308, n)))
    end
end