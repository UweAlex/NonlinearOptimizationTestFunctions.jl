# test/schwefel26_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "schwefel26" begin
    tf = SCHWEFEL26_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel26.jl")[1:end-3]  # Dynamisch: "schwefel26"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 7.0 atol=1e-3  # max(|0+0-7|, |0+0-5|) = 7
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Exakte Prüfung, kein Noise
    
    # Extra: Gradient at minimum should be zero (subgradient choice)
    @test all(isapprox.(tf.grad(min_pos), zeros(2), atol=1e-8))  # [RULE_TEST_SYNTAX]
    
    # Extra: Check gradient in region where u > v, e.g. at [0,0] should be sign(-7)*[1,2] = -[1,2]
    grad_start = tf.grad(start_point)
    @test isapprox(grad_start, [-1.0, -2.0], atol=1e-8)
end