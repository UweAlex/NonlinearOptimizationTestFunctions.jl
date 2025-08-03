# test/himmelblau_tests.jl
# Purpose: Tests for the Himmelblau function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 03 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: HIMMELBLAU_FUNCTION, himmelblau

@testset "Himmelblau Tests" begin
    tf = HIMMELBLAU_FUNCTION
    n = 2
    @test_throws ArgumentError himmelblau(Float64[])
    @test isnan(himmelblau(fill(NaN, n)))
    @test isinf(himmelblau(fill(Inf, n)))
    @test isfinite(himmelblau(fill(1e-308, n)))
    @test himmelblau(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test himmelblau(tf.meta[:start](n)) ≈ 170.0 atol=1e-6
    @test tf.meta[:name] == "himmelblau"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [3.0, 2.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-5.0, -5.0]
    @test tf.meta[:ub](n) == [5.0, 5.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "differentiable", "non-convex", "bounded"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        minima = [[3.0, 2.0], [-2.805118, 3.131312], [-3.779310, -3.283186], [3.584428, -1.848126]]
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end
end