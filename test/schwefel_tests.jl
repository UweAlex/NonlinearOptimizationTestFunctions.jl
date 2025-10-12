# test/schwefel_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "schwefel" begin
    tf = SCHWEFEL_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel.jl")[1:end-3]  # Dynamisch: "schwefel"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "partially separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Beispiel-Check
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(isapprox.(min_pos, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8  # min_value mit (n); kein Noise [RULE_ATOL]
    
    # Extra: Gradient-Check am Minimum (sollte zeros sein)
    grad_min = tf.grad(min_pos)
    @test all(isapprox.(grad_min, zeros(n), atol=1e-8))
    
    # Extra: Check bei n=10 (skalierbar)
    n_extra = 10
    min_pos_extra = tf.meta[:min_position](n_extra)
    @test tf.f(min_pos_extra) ≈ tf.meta[:min_value](n_extra) atol=1e-8
end