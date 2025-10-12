# test/schwefel223_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "schwefel223" begin
    tf = SCHWEFEL223_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel223.jl")[1:end-3]  # Dynamisch: "schwefel223"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Start at zeros
    @test tf.f(start_point) ≈ 0.0 atol=1e-8  # At zeros: 0
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(isapprox.(min_pos, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # Exakte Prüfung, kein Noise
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    
    # Extra: Check for n=2, e.g. at [1, 2]: f = 1^10 + 2^10 = 1 + 1024 = 1025, grad = [10*1^9, 10*2^9] = [10, 5120]
    n_extra = 2
    test_point = [1.0, 2.0]
    @test tf.f(test_point) ≈ 1025.0 atol=1e-8
    @test all(isapprox.(tf.grad(test_point), [10.0, 5120.0], atol=1e-8))
end