# test/qing_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "qing" begin
    tf = QING_FUNCTION
    @test tf.meta[:name] == "qing"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    n = 2
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Check gradient at minimum
    grad_at_min = tf.grad(min_pos)
    @test all(abs.(grad_at_min) .< 1e-8)
    
    # Check another minimum with negative sign
    min_pos_neg = [-sqrt(1.0), sqrt(2.0)]
    @test tf.f(min_pos_neg) ≈ 0.0 atol=1e-8
end