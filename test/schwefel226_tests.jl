# test/schwefel226_tests.jl

using Test, NonlinearOptimizationTestFunctions
using LinearAlgebra: norm  # For position check if needed

@testset "schwefel226" begin
    tf = SCHWEFEL226_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel226.jl")[1:end-3]  # Dynamisch: "schwefel226"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Start at zeros
    @test tf.f(start_point) ≈ 0.0 atol=1e-8  # At zeros: 0
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(isapprox.(min_pos, fill(420.96874357691473, n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # Exakte Prüfung, kein Noise
    
    # Extra: Gradient at minimum should be near zero (periodic, but at global max of term)
    @test all(isapprox.(tf.grad(min_pos), zeros(n), atol=1e-4))  # [RULE_TEST_SYNTAX] (tol looser due to trig)
end