# test/rump_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "rump" begin
    tf = RUMP_FUNCTION
    @test tf.meta[:name] == "rump"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "partially differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    @test tf.meta[:properties_source] == "Al-Roomi (2015)"
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 226.5833 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
   
end