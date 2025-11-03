# test/trid6_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "trid6" begin
    tf = TRID6_FUNCTION
    @test tf.meta[:name] == "trid6"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 6.0 atol=1e-3  # Computed: sum((0-1)^2 * 6) = 6.0
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
end