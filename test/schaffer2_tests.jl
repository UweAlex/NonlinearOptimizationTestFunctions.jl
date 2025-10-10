# test/schaffer2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "schaffer2" begin
    tf = SCHAFFER2_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schaffer2.jl")[1:end-3]  # Dynamisch: "schaffer2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "non-separable")
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test tf.f(start_point) ≈ 0.488 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test all(min_pos .== 0)
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Check gradient at minimum
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-8))  # isapprox für Vektor [RULE_TEST_SYNTAX]
end