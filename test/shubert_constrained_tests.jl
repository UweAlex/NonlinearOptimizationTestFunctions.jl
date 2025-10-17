# test/shubert_constrained_tests.jl
using Test, NonlinearOptimizationTestFunctions
using ForwardDiff

@testset "shubert_constrained" begin
    tf = SHUBERT_CONSTRAINED_FUNCTION
    
    # [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/shubert_constrained.jl")[1:end-3]
    
    # [RULE_DEFAULT_N]
    @test haskey(tf.meta, :default_n)
    @test tf.meta[:default_n] >= 2
    n = tf.meta[:default_n]
    
    # [VALID_PROPERTIES]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "constrained")
    
    # Start
    start_pt = tf.meta[:start](n)
    @test length(start_pt) == n
    @test all(isapprox.(start_pt, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    @test tf.meta[:constraints](start_pt) <= 0  # [RULE_CONSTRAINED]
    
    # Minimum
    min_pos = tf.meta[:min_position](n)
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8  # [RULE_ATOL]
    @test tf.meta[:constraints](min_pos) <= 0  # [RULE_CONSTRAINED]
    
    # Zusätzliches Minimum (aus Liste der 18 Minima, feasible)
    min_pos_alt = [-7.0835, -0.8003]  # sum = -7.8838 ≤ 0
    @test tf.f(min_pos_alt) ≈ tf.meta[:min_value](n) atol=1e-8
    @test tf.meta[:constraints](min_pos_alt) <= 0
    
    # Gradient
    grad = tf.grad(min_pos)  # [RULE_TESTFUNCTION_FIELDS]
    @test length(grad) == n
    grad_fd = ForwardDiff.gradient(tf.f, min_pos)
    @test all(isapprox.(grad, grad_fd, atol=1e-6))  # [RULE_TEST_SYNTAX]
    
    # Type-Stability
    @test @inferred(tf.f(rand(n))) isa Real
    
    # Fehlerfälle
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN]))
    @test isinf(tf.f([Inf]))
end