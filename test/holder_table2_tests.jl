# test/holder_table2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "holder_table2" begin
    tf = HOLDER_TABLE2_FUNCTION
    @test tf.meta[:name] == "holder_table2"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ -0.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-3
    
    # Check another global minimum
    min_pos_alt = [-8.051, 10.0]
    @test tf.f(min_pos_alt) ≈ -11.6839 atol=1e-3
    
    
end