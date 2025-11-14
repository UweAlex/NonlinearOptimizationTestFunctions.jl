# test/wolfe_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "wolfe" begin
    tf = WOLFE_FUNCTION
    @test tf.meta[:name] == "wolfe"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "partially separable")  # Fix: partially statt non-separable
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 7/3 atol=1e-8  # Exakt (4/3)*1^{0.75} +1 = 7/3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # 0.0 ≈ 0.0
    
    # Gradient at start
    grad_start = tf.grad(start_point)
    @test grad_start ≈ [1.0, 1.0, 1.0] atol=1e-8
    
    # Gradient at min ([0,0,1] per Limit-Handling)
    grad_min = tf.grad(min_pos)
    @test grad_min[1] ≈ 0 atol=1e-8
    @test grad_min[2] ≈ 0 atol=1e-8
    @test grad_min[3] ≈ 1 atol=1e-8
    
    # Optional: High-Prec-Validierung [RULE_HIGH_PREC_SUPPORT]
    # @testset "BigFloat" begin
    #     using BigFloat
    #     setprecision(256)
    #     bf_min_pos = BigFloat.([0,0,0])
    #     @test tf.f(bf_min_pos) ≈ BigFloat(0) atol=BigFloat("1e-15")
    # end
end