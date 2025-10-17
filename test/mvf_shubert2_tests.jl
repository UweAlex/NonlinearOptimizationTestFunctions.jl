# test/mvf_shubert2_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "mvf_shubert2" begin
    tf = MVF_SHUBERT2_FUNCTION
    @test tf.meta[:name] == "mvf_shubert2"  # [RULE_NAME_CONSISTENCY]
    @test property(tf, "separable")  # Properties-Check
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Fixed 2D
end