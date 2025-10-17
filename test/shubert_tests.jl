# test/shubert_tests.jl

using Test, NonlinearOptimizationTestFunctions
using Optim  # For Nelder-Mead
using LinearAlgebra: norm  # For gradient norm

@testset "shubert" begin
    tf = SHUBERT_FUNCTION
    @test tf.meta[:name] == basename("src/functions/shubert.jl")[1:end-3]  # Dynamisch: "shubert"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "controversial")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 19.8758 atol=1e-3  # Computed at [0,0]
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Precise match
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(2), atol=1e-5))  # [RULE_TEST_SYNTAX] (looser for numerical precision)
    
end