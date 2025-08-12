# test/zakharov_tests.jl
# Purpose: Tests for the Zakharov function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: August 12, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: ZAKHAROV_FUNCTION, zakharov

@testset "Zakharov Tests" begin
    tf = ZAKHAROV_FUNCTION
    n = 2
    @test_throws ArgumentError zakharov(Float64[])
    @test isnan(zakharov(fill(NaN, n)))
    @test isinf(zakharov(fill(Inf, n)))
    @test isfinite(zakharov(fill(1e-308, n)))
    @test zakharov(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test zakharov(tf.meta[:start](n)) ≈ 9.3125 atol=1e-6
    @test tf.meta[:name] == "zakharov"
    @test tf.meta[:start](n) == ones(n)
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == fill(-5.0, n)
    @test tf.meta[:ub](n) == fill(10.0, n)
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable"])
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end