# test/trigonometric2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "trigonometric2" begin
    tf = TRIGONOMETRIC2_FUNCTION
    @test tf.meta[:name] == "trigonometric2"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Check: zeros(n)
    @test all(start_point .>= tf.meta[:lb](n)) && all(start_point .<= tf.meta[:ub](n))  # Within bounds
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(abs.(min_pos .- 0.9) .< 1e-10)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # [RULE_TEST_SYNTAX]; min_value mit (n)
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(n), atol=1e-8))
    
    # Edge case: n=1 (minimal scalable)
    min_pos_1 = tf.meta[:min_position](1)
    @test tf.f(min_pos_1) ≈ 1.0 atol=1e-8
end