# test/threehumpcamel_tests.jl
# Purpose: Tests for the Three-Hump Camel function implementation.
# Context: Part of the test suite for NonlinearOptimizationTestFunctions.
# Last modified: 15 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

tf = NonlinearOptimizationTestFunctions.THREEHUMPCAMEL_FUNCTION

@testset "Three-Hump Camel Function Tests" begin
    n = 2
    @test tf.meta[:name] == "threehumpcamel"
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:min_position](n) ≈ [0.0, 0.0]
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "bounded")

    # Function value at minimum
    @test tf.f(tf.meta[:min_position](n)) ≈ 0.0 atol=1e-10

    # Function value at start point [2.0, 2.0]
    @test tf.f(tf.meta[:start](n)) ≈ 9.866666666666667 atol=1e-10

    # Optimization test with L-BFGS
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ 0.0 atol=1e-3
    @test Optim.minimizer(result) ≈ [0.0, 0.0] atol=1e-3 rtol=1e-3

    # Incorrect dimension test
    @test_throws ArgumentError tf.f([1.0, 1.0, 1.0])
end