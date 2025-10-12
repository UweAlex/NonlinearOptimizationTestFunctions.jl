# test/schwefel225_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "schwefel225" begin
    tf = SCHWEFEL225_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel225.jl")[1:end-3]  # Dynamisch: "schwefel225"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 416.0 atol=1e-3  # Computed: (5-1)^2 + (5-25)^2 = 16 + 400 = 416
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Exakte Prüfung, kein Noise
    
    # Extra: Gradient at minimum should be zero
    @test all(isapprox.(tf.grad(min_pos), zeros(2), atol=1e-8))  # [RULE_TEST_SYNTAX]
end