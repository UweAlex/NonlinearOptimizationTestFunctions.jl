# test/rotatedellipse2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "rotatedellipse2" begin
    tf = ROTATEDELLIPSE2_FUNCTION
    @test tf.meta[:name] == "rotatedellipse2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "convex")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 1.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(length(min_pos)), atol=1e-8))
end