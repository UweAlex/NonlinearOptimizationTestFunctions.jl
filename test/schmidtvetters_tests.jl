# test/schmidtvetters_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "schmidtvetters" begin
    tf = SCHMIDTVETTERS_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schmidtvetters.jl")[1:end-3]  # Dynamisch: "schmidtvetters"
    @test has_property(tf, "partially differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 2.8775825618903728 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
end