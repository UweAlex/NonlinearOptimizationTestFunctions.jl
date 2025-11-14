# test/whitley_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "whitley" begin
    tf = WHITLEY_FUNCTION
    @test tf.meta[:name] == "whitley"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    
    n = tf.meta[:default_n]  # Use default_n for standard tests
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0.0)  # Check for zeros(n)
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(min_pos .== 1.0)  # Check for ones(n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # Standard atol for non-noisy
    
    # Start away from min [RULE_START_AWAY_FROM_MIN]
    @test tf.f(start_point) > tf.meta[:min_value](n) + 1e-3
    
    # Gradient at minimum should be zero [RULE_TEST_SYNTAX]
    @test all(isapprox.(tf.grad(min_pos), 0, atol=1e-8))
    
    # Optional: High-Prec validation [RULE_HIGH_PREC_SUPPORT]
    # using BigFloat; setprecision(256); @test tf.f(BigFloat.(min_pos)) ≈ BigFloat(tf.meta[:min_value](n)) atol=BigFloat("1e-15")
end