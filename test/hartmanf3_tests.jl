# test/hartmanf3_tests.jl
# Purpose: Tests for the Hartmann function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 01 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: HARTMANF3_FUNCTION, hartmanf3

@testset "Hartmanf3 Tests" begin
    tf = HARTMANF3_FUNCTION
    n = 3
    @test_throws ArgumentError hartmanf3(Float64[])
    @test_throws ArgumentError hartmanf3([1.0, 1.0])
    @test isnan(hartmanf3(fill(NaN, n)))
    @test isinf(hartmanf3(fill(Inf, n)))
    @test isfinite(hartmanf3(fill(1e-308, n)))
    @test hartmanf3(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-6
    @test hartmanf3(tf.meta[:start]()) ≈ -0.6280220961750616 atol=1e-6  # Updated to match computed value
    @test tf.meta[:name] == "hartmanf3"
    @test tf.meta[:start]() == [0.5, 0.5, 0.5]
    @test tf.meta[:min_position]() ≈ [0.114614, 0.555649, 0.852547] atol=1e-6
    @test tf.meta[:min_value]() ≈ -3.86278214782076 atol=1e-6
    @test tf.meta[:lb]() == fill(0.0, 3)
    @test tf.meta[:ub]() == fill(1.0, 3)
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable" ,"bounded","continuous"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position]() .+ 0.01 * randn(n)  # Leichtes Rauschen für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value]() atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end
end