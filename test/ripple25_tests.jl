# test/ripple25_tests.jl

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "ripple25" begin
    tf = RIPPLE25_FUNCTION
    
    @test tf.meta[:name] == "ripple25"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test length(tf.meta[:properties]) == 5
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    @test_throws ArgumentError tf.f(Float64[])
    
    start_point = tf.meta[:start]()
    @test start_point ≈ [0.5, 0.5] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ -1.4142135623730951 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [0.1, 0.1] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8
    
    lb = tf.meta[:lb]()
    @test lb ≈ [0.0, 0.0]
    ub = tf.meta[:ub]()
    @test ub ≈ [1.0, 1.0]
    
    # Extra point
    test_pt = [0.0, 0.0]
    @test tf.f(test_pt) ≈ 0.0 atol=1e-3
    
    # Gradient at minimum should be zero
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-8))
    
    # AD gradient match
    ad_grad = ForwardDiff.gradient(tf.f, min_pos)
    @test ad_grad ≈ grad_at_min atol=1e-8
end