# test/xin_she_yang3_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "xin_she_yang3" begin
    tf = XIN_SHE_YANG3_FUNCTION
    @test tf.meta[:name] == "xin_she_yang3"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 1.0)  # Beispiel-Check
    @test tf.f(start_point) > tf.meta[:min_value](n) + 1e-3  # [NEW RULE_START_AWAY_FROM_MIN]
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # [RULE_TEST_SYNTAX]; nun -1.0
    
    # Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(n), atol=1e-8))
    
    # Optional: High-Prec-Validierung [RULE_HIGH_PREC_SUPPORT]
    # using BigFloat; setprecision(256); @test tf.f(BigFloat.(min_pos)) ≈ BigFloat(tf.meta[:min_value](n)) atol=BigFloat("1e-15")
end