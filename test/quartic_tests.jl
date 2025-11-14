# test/quartic_tests.jl
# Purpose: Unit tests for the Quartic Function.
# Last modified: October 02, 2025.

using Test, NonlinearOptimizationTestFunctions

@testset "quartic" begin
    tf = QUARTIC_FUNCTION
    @test tf.meta[:name] == "quartic"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "has_noise")
    @test has_property(tf, "unimodal")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
   
    
    min_pos = tf.meta[:min_position](n)
    # Due to additive uniform noise [0,1), f at minimum is in [0,1)
    f_min = tf.f(min_pos)
    @test f_min >= 0
    @test f_min < 1
    
    # Gradient at minimum (deterministic part) should be zero
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(n), atol=1e-8))
end