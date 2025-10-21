# test/shubert_classic_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "shubert_classic" begin
    tf = SHUBERT_CLASSIC_FUNCTION
    @test tf.meta[:name] == basename("src/functions/shubert_classic.jl")[1:end-3]  # Dynamisch: "shubert_classic"
    
    # Test Properties (für jede aus :properties)
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "highly multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "controversial")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 19.875836249802127 atol=1e-3  # Genaues Start-Wert (via REPL-Berechnung)
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Exakte Übereinstimmung
    
end