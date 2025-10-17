# test/shubert_shifted_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "shubert_shifted" begin
    tf = SHUBERT_SHIFTED_FUNCTION
    @test tf.meta[:name] == "shubert_shifted"  # [RULE_NAME_CONSISTENCY]
    @test property(tf, "non-separable")  # Properties-Check
    
    n = tf.meta[:default_n]  # 2 [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # Deviation <1e-6
end