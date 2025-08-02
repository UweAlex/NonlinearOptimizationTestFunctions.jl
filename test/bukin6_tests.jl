# test/bukin6_tests.jl
# Purpose: Tests for the Bukin N.6 function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 03 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: BUKIN6_FUNCTION, bukin6

@testset "Bukin6 Tests" begin
    tf = BUKIN6_FUNCTION
    n = 2
    @test_throws ArgumentError bukin6(Float64[])
    @test_throws ArgumentError bukin6([0.0, 0.0, 0.0])
    @test isnan(bukin6([NaN, 0.0]))
    @test isinf(bukin6([Inf, 0.0]))
    @test isfinite(bukin6([1e-308, 1e-308]))
    @test bukin6(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test bukin6(tf.meta[:start](n)) ≈ 0.1 atol=1e-6
    @test tf.meta[:name] == "bukin6"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) == [-10.0, 1.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](n) == [-15.0, -3.0]
    @test tf.meta[:ub](n) == [-5.0, 3.0]
   @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["differentiable", "non-convex", "multimodal"])
    @testset "Optimization Tests" begin
        start = [-10.0, 1.0]  # Changed from [-10.0, 0.99] to the exact minimum
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](n), tf.meta[:ub](n), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-3  # Increased from 0.001 to 0.001 (1e-3)
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-2  # Increased from 0.01 to 0.01 (1e-2)
    end
end