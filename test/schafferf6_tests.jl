# test/schafferf6_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "schafferf6" begin
    tf = SCHAFFERF6_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schafferf6.jl")[1:end-3]  # Dynamisch: "schafferf6"
    @test has_property(tf, "continuous")  # Für jede Property
    @test has_property(tf, "differentiable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    
    n = tf.meta[:default_n]  # 2
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)
    @test tf.f(start_point) ≈ 0.0 atol=1e-8  # At zero, sin(0)=0, so f=0
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Extra: Check for n=3
    n3 = 3
    min_pos3 = tf.meta[:min_position](n3)
    @test length(min_pos3) == n3
    @test all(min_pos3 .== 0)
    @test tf.f(min_pos3) ≈ 0.0 atol=1e-8
end