# test/wayburnseader1_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "wayburnseader1" begin
    tf = WAYBURNSEADER1_FUNCTION
    @test tf.meta[:name] == "wayburnseader1"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "bounded")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 305.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Extra: Check another minimum
    min_pos_alt = [1.596804153876933, 0.806391692246134]
    @test tf.f(min_pos_alt) ≈ 0.0 atol=1e-8
end