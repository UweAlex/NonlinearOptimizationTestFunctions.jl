# test/zirilli_aluffipentini_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "zirilli_aluffipentini" begin
    tf = ZIRILLI_ALUFFIPENTINI_FUNCTION
    @test tf.meta[:name] == "zirilli_aluffipentini"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) > tf.meta[:min_value]() + 1e-3  # [NEW RULE_START_AWAY_FROM_MIN]
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # [RULE_TEST_SYNTAX]
    
    # Optional: High-Prec-Validierung [RULE_HIGH_PREC_SUPPORT]
    # using BigFloat; setprecision(256); @test tf.f(BigFloat.([BigFloat("-1.0465"), 0.0])) ≈ BigFloat(-0.3523) atol=BigFloat("1e-15")
end