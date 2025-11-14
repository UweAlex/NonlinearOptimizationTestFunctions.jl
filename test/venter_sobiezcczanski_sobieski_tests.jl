# test/venter_sobiezcczanski_sobieski_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "venter_sobiezcczanski_sobieski" begin
    tf = VENTER_SOBIEZCCZANSKI_SOBIESKI_FUNCTION
    @test tf.meta[:name] == "venter_sobiezcczanski_sobieski"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    
    start_point = tf.meta[:start]()
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
end