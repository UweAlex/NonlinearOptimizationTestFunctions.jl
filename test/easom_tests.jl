# test/easom_tests.jl
# Purpose: Tests for the Easom function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 21 July 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: EASOM_FUNCTION, easom

@testset "Easom Tests" begin
    tf = EASOM_FUNCTION
    @test_throws ArgumentError easom(Float64[])
    @test isnan(easom(fill(NaN, 2)))
    @test isinf(easom(fill(Inf, 2)))
    @test isfinite(easom(fill(1e-308, 2)))
    @test easom(tf.meta[:min_position]()) ≈ -1.0 atol=1e-6
    @test easom(tf.meta[:start]()) ≈ -2.67205116805576e-9 atol=1e-6
    @test tf.meta[:name] == "easom"
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [pi, pi] atol=1e-6
    @test tf.meta[:min_value]() ≈ -1.0 atol=1e-6
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded","continuous"])
end