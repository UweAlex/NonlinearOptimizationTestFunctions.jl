# tests/schumersteiglitz_tests.jl
# Purpose: Unit tests for the Schumer-Steiglitz test function.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 10, 2025

using Test, NonlinearOptimizationTestFunctions

@testset "schumersteiglitz" begin
    tf = SCHUMERSTEIGLITZ_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schumersteiglitz.jl")[1:end-3]

    # Test properties
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")

    n = tf.meta[:default_n]
    @test n >= 2

    start_point = tf.meta[:start](n)
    @test length(start_point) == n

    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8

    # Extra: Simple check at all-ones point
    x_test = fill(1.0, n)
    @test tf.f(x_test) ≈ n atol=1e-8
end