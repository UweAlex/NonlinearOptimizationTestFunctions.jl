#test/quintic_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "quintic" begin
    tf = QUINTIC_FUNCTION
    @test tf.meta[:name] == "quintic"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 8.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Gradient-Test
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(length(min_pos)), atol=1e-8))
    
    # Extra: Check another minimum (mixture of -1 and 2)
    min_pos_alt = [-1.0, 2.0]
    @test tf.f(min_pos_alt) ≈ 0.0 atol=1e-8
    
    # Gradient at start
    grad_at_start = tf.grad(start_point)
    @test all(isapprox.(grad_at_start, [10.0, 10.0], atol=1e-8))
end