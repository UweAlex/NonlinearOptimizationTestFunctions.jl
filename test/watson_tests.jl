# test/watson_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "watson" begin
    tf = WATSON_FUNCTION
    @test tf.meta[:name] == "watson"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    
    # Properties-Tests (alle aus VALID_PROPERTIES)
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "controversial")
    
    # Start-Point-Test
    start_point = tf.meta[:start]()
    @test length(start_point) == 6
    @test all(start_point .== 0.0)  # zeros(6)
    @test tf.f(start_point) ≈ 29.0 atol=1e-3  # Bekannter Wert bei Start
    
    # Minimum-Test (mit neuen präzisen Werten)
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 6
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-6  # Präzise Übereinstimmung
    
    # Gradient-Test am Minimum (sollte Null sein)
    grad_at_min = tf.grad(min_pos)
    @test grad_at_min ≈ zeros(6) atol=1e-6
    
    # Extra: Bounds-Check (Start in Bounds)
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test all(start_point .>= lb) && all(start_point .<= ub)
end