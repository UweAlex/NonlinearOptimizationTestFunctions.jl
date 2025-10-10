# test/holdertable_tests.jl
# Purpose: Tests for the Holder Table function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: August 26, 2025

using Test
using Optim
using NonlinearOptimizationTestFunctions: HOLDERTABLE_FUNCTION, holdertable

@testset "HolderTable Tests" begin
    tf = HOLDERTABLE_FUNCTION
    n = 2  # Holder Table ist nur für n=2 definiert

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "holdertable"
        @test isfinite(holdertable(tf.meta[:lb]()))
        @test isfinite(holdertable(tf.meta[:ub]()))
        @test isfinite(holdertable(fill(1e-308, n)))
        @test isinf(holdertable(fill(Inf, n)))
        @test holdertable(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
        @test holdertable([0.0, 0.0]) ≈ 0.0 atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [8.055023, 9.664590] atol=1e-6
        @test tf.meta[:min_value]() ≈ -19.2085025678845 atol=1e-6
        @test tf.meta[:lb]() == [-10.0, -10.0]
        @test tf.meta[:ub]() == [10.0, 10.0]
        @test tf.meta[:properties] == Set(["multimodal", "continuous", "partially differentiable", "separable", "bounded", "non-convex"])
    end

    @testset "Edge Cases" begin
        @test_throws ArgumentError holdertable(Float64[])
        @test_throws ArgumentError holdertable([1.0])
        @test_throws ArgumentError holdertable([1.0, 2.0, 3.0])
        @test isnan(holdertable(fill(NaN, n)))
        @test isinf(holdertable(fill(Inf, n)))
        @test isfinite(holdertable(fill(1e-308, n)))
    end
end