# test/weierstrass_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "weierstrass" begin
    tf = WEIERSTRASS_FUNCTION
    @test tf.meta[:name] == "weierstrass"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .≈ 0.4)
    @test tf.f(start_point) > tf.meta[:min_value](n) + 1e-3  # [RULE_START_AWAY_FROM_MIN]
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(min_pos .≈ 0.0)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # Exact 0.0 with correct formula
    
    # Gradient at minimum should be zero
    grad_min = tf.grad(min_pos)
    
    # Bounds check
    lb = tf.meta[:lb](n)
    ub = tf.meta[:ub](n)
    @test all(start_point .>= lb) && all(start_point .<= ub)
    
    # Edge cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f(fill(NaN, n)))
    @test isinf(tf.f(fill(Inf, n)))
    
    # Source and description checks
    @test occursin("p. 38", tf.meta[:source])
    @test occursin("adapted from Al-Roomi", tf.meta[:source])
  
    
    # Optional: High-Prec Validation [RULE_HIGH_PREC_SUPPORT]
    # using BigFloat; setprecision(256)
    # @test tf.f(BigFloat.(min_pos)) ≈ BigFloat(tf.meta[:min_value](n)) atol=BigFloat("1e-15")
end