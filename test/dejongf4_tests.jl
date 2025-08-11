# test/dejongf4_tests.jl
# Purpose: Tests for the De Jong F4 function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 11 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: DEJONGF4_FUNCTION, dejongf4
using Random

@testset "De Jong F4 Tests" begin
    tf = DEJONGF4_FUNCTION
    n = 2
    Random.seed!(1234)  # Für reproduzierbare Tests
    @test_throws ArgumentError dejongf4(Float64[])
    @test isnan(dejongf4(fill(NaN, n)))
    @test isinf(dejongf4(fill(Inf, n)))
    @test isfinite(dejongf4(fill(1e-308, n)))
    @test abs(dejongf4(tf.meta[:min_position](n)) - tf.meta[:min_value]) <= 1.0  # Noise in [0,1)
    @test abs(dejongf4(tf.meta[:start](n)) - tf.meta[:min_value]) <= 1.0  # Start at zeros
    @test tf.meta[:name] == "dejongf4"
    @test tf.meta[:start](n) == zeros(n)
    @test tf.meta[:min_position](n) == zeros(n)
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == fill(-1.28, n)
    @test tf.meta[:ub](n) == fill(1.28, n)
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "separable", "partially differentiable", "scalable", "continuous", "bounded", "has_noise"])
    @testset "Optimization Tests" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test abs(Optim.minimum(result) - tf.meta[:min_value]) <= 1.0  # Noise in [0,1)
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end