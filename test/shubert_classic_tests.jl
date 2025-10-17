# test/shubert_classic_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "shubert_classic" begin
    tf = SHUBERT_CLASSIC_FUNCTION
    @test tf.meta[:name] == "shubert_classic"  # [RULE_NAME_CONSISTENCY]
    @test property(tf, "highly multimodal")  # Properties-Check (via property, deprecated has_property)
    
    n = tf.meta[:default_n]  # 2 [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test all(isapprox.(tf.f(min_pos), tf.meta[:min_value](n), atol=1e-8))  # Skalar [RULE_TEST_SYNTAX]
end