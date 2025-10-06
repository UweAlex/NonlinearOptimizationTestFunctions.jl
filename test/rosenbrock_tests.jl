# test/rosenbrock_tests.jl

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "rosenbrock" begin
    tf = ROSENBROCK_FUNCTION
    
    @test tf.meta[:name] == "rosenbrock"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "ill-conditioned")
    @test length(tf.meta[:properties]) == 7
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0])  # n=1 invalid
    
    n = tf.meta[:default_n]
    @test n == 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test start_point ≈ [-1.2, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 24.2 atol=1e-3
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(isapprox.(min_pos, ones(n), atol=1e-8))
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8
    
    lb = tf.meta[:lb](n)
    @test length(lb) == n
    @test all(lb .== -30.0)
    ub = tf.meta[:ub](n)
    @test length(ub) == n
    @test all(ub .== 30.0)
    
    # Extra point: [0.0, 0.0] for n=2
    test_pt = zeros(n)
    @test tf.f(test_pt) ≈ 1.0 atol=1e-3
    
    # Gradient at minimum should be zero
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(n), atol=1e-8))
    
    # AD gradient match
    ad_grad = ForwardDiff.gradient(tf.f, min_pos)
    @test ad_grad ≈ grad_at_min atol=1e-8
end