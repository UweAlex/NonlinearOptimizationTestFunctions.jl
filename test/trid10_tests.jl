# test/trid10_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "trid10" begin
    tf = TRID10_FUNCTION
    @test tf.meta[:name] == "trid10"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 10.0 atol=1e-3  # Computed: sum((0-1)^2 * 10) = 10.0, minus 0 = 10? Wait, sum1=10, sum2=0, yes but wait: for zeros, sum1=10*1=10, sum2=0, yes ≈10.0
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
end