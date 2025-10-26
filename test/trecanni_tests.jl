# test/trecanni_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "trecanni" begin
    tf = TRECANNI_FUNCTION
    @test tf.meta[:name] == "trecanni"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "separable")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 2.0 atol=1e-3  # f(-1,1) = [1 -4 +4] +1 =1+1=2
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # 0.0
    
    # Test another global minimum
    min_pos_alt = [0.0, 0.0]
    @test tf.f(min_pos_alt) ≈ 0.0 atol=1e-8
    
    # Bounds check
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test all(lb .== -5.0)
    @test all(ub .== 5.0)
end