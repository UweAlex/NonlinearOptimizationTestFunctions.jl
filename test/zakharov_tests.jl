# test/zakharov_tests.jl
# Purpose: Tests for the Zakharov function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: ZAKHAROV_FUNCTION, zakharov

@testset "Zakharov Tests" begin
    tf = ZAKHAROV_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    min_value = tf.meta[:min_value](n)

    # Test Funktionswerte
    @test zakharov(start) ≈ 9.3125 atol=1e-6  # f([1, 1]) = 2 + (0.5 + 1)^2 + (0.5 + 1)^4 = 9.3125
    @test zakharov(min_pos) ≈ min_value atol=1e-6  # min_pos = [0, 0], min_value = 0

    # Test Edge Cases
    @test_throws ArgumentError zakharov(Float64[])
    @test isnan(zakharov(fill(NaN, n)))
    @test isinf(zakharov(fill(Inf, n)))
    @test isfinite(zakharov(fill(1e-308, n)))

    # Test Metadaten
    @test tf.meta[:name] == "zakharov"
    @test tf.meta[:start](n) == ones(n)
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:min_value](n) ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == fill(-5.0, n)
    @test tf.meta[:ub](n) == fill(10.0, n)
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test tf.meta[:properties] == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable", "bounded", "continuous"])

 
end