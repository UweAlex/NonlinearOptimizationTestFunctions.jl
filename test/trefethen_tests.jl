# test/trefethen_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "trefethen" begin
    tf = TREFETHEN_FUNCTION
    @test tf.meta[:name] == "trefethen"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")  # Für jede Property
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.695 atol=1e-3  # Computed via REPL/Python equivalent
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Passe an: () oder (n); für Noise: Range-Check
end