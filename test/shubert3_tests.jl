# test/shubert3_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "shubert3" begin
    tf = SHUBERT3_FUNCTION
    @test tf.meta[:name] == basename("src/functions/shubert3.jl")[1:end-3]  # Dynamisch: "shubert3"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "controversial")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ -14.215216475725633  atol=1e-3  # At zeros: 0
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-4  # Source value, loose atol for controversy
    
  
end