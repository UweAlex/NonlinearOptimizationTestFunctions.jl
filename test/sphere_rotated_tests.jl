# test/sphere_rotated_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "sphere_rotated" begin
    tf = SPHERE_ROTATED_FUNCTION
    @test tf.meta[:name] == basename("src/functions/sphere_rotated.jl")[1:end-3]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "convex")
    @test has_property(tf, "unimodal")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
end