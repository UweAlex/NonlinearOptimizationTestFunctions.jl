# test/shubert_generalized_tests.jl
using Test, NonlinearOptimizationTestFunctions
using ForwardDiff

@testset "shubert_generalized" begin
    tf = SHUBERT_GENERALIZED_FUNCTION
    
    # [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/shubert_generalized.jl")[1:end-3]
    
    # [RULE_DEFAULT_N]
    @test haskey(tf.meta, :default_n)
    @test tf.meta[:default_n] >= 2
    n = tf.meta[:default_n]
    
    # [VALID_PROPERTIES]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "separable")
    
    # Start
    start_pt = tf.meta[:start](n)
    @test length(start_pt) == n
    @test all(isapprox.(start_pt, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    
    # Minimum
    min_pos = tf.meta[:min_position](n)
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8  # [RULE_ATOL]
    @test all(isapprox.(min_pos, fill(-1.42512843, n), atol=1e-8))
    
    # Gradient
    grad = tf.grad(min_pos)  # [RULE_TESTFUNCTION_FIELDS]
    @test length(grad) == n
    grad_fd = ForwardDiff.gradient(tf.f, min_pos)
    @test all(isapprox.(grad, grad_fd, atol=1e-6))  # [RULE_TEST_SYNTAX]
    
    # Type-Stability
    @test @inferred(tf.f(rand(n))) isa Real
end