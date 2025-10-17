# test/shekel5_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "shekel5" begin
    tf = SHEKEL5_FUNCTION
    @test tf.meta[:name] == basename("src/functions/shekel5.jl")[1:end-3]  # Dynamisch: "shekel5"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "controversial")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ -5.0552 atol=1e-3  # Computed at [1,1,1,1]
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Etwas lockerer atol für Summen
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(4), atol=1e-5))  # [RULE_TEST_SYNTAX] (looser for numerical precision)
end