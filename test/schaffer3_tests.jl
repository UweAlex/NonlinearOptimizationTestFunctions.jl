# test/schaffer3_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "schaffer3" begin
    tf = SCHAFFER3_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schaffer3.jl")[1:end-3]  # Dynamisch: "schaffer3"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.708073418273571 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Gradient-Test
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(length(min_pos)), atol=1e-8))
end