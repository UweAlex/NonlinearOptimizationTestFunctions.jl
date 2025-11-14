# test/ursem_waves_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "ursem_waves" begin
    tf = URSEM_WAVES_FUNCTION
    @test tf.meta[:name] == "ursem_waves"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "non-separable")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
end