# test/wayburnseader3_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "wayburnseader3" begin
    tf = WAYBURNSEADER3_FUNCTION
    @test tf.meta[:name] == "wayburnseader3"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 1374 atol=1e-8  # Exact f([0,0]) = 1374.0 [RULE_ATOL]
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # ≈19.10588
end