# test/schwefel236_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "schwefel236" begin
    tf = SCHWEFEL236_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel236.jl")[1:end-3]  # Dynamisch: "schwefel236"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 58000000.0 atol=1e-3  # Corrected: -250*250*(72-500-500) = 62500 * (-928) = -58e6, then f = -(-58e6) = +58e6
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Exakte Prüfung, kein Noise
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(2), atol=1e-8))  # [RULE_TEST_SYNTAX]
end