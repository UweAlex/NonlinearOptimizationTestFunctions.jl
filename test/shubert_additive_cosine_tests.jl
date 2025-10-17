# test/shubert_additive_cosine_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "shubert_additive_cosine" begin
    tf = SHUBERT_ADDITIVE_COSINE_FUNCTION
    @test tf.meta[:name] == "shubert_additive_cosine"  # [RULE_NAME_CONSISTENCY]
    @test property(tf, "separable")  # Properties-Check
    
    n = tf.meta[:default_n]  # 2 [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # n-abhängig
end