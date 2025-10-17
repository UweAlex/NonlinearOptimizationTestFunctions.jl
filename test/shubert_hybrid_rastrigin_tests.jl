# test/shubert_hybrid_rastrigin_tests.jl
using Test, NonlinearOptimizationTestFunctions
using ForwardDiff

@testset "shubert_hybrid_rastrigin" begin
    tf = SHUBERT_HYBRID_RASTRIGIN_FUNCTION
    
    # [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/shubert_hybrid_rastrigin.jl")[1:end-3]
    
    # [VALID_PROPERTIES]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "ill-conditioned")
    
    # Start
    start_pt = tf.meta[:start]()
    @test length(start_pt) == 2
    @test all(isapprox.(start_pt, [0.0, 0.0], atol=1e-8))  # [RULE_TEST_SYNTAX]
    
    # Minimum
    min_pos = tf.meta[:min_position]()
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8  # [RULE_ATOL]
    @test all(isapprox.(min_pos,  [-0.8130518668176654, -1.4178774389880957], atol=1e-8))
    
    # Gradient
    grad = tf.grad(min_pos)  # [RULE_TESTFUNCTION_FIELDS]
    @test length(grad) == 2
    grad_fd = ForwardDiff.gradient(tf.f, min_pos)
    @test all(isapprox.(grad, grad_fd, atol=1e-6))  # [RULE_TEST_SYNTAX]
    
    # Type-Stability
    @test @inferred(tf.f(rand(2))) isa Real
    
    # Fehlerfälle
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f(rand(3))
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
end