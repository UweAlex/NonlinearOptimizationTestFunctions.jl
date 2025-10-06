# test/rotatedellipse_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "rotatedellipse" begin
    tf = ROTATEDELLIPSE_FUNCTION
    
    # Test metadata
    @test tf.meta[:name] == "rotatedellipse"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "convex")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    # Test dimension requirement
    @test_throws ArgumentError tf.f([1.0])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    
    # Test start point
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    # f([1,1]) = 7(1)² - 6√3(1)(1) + 13(1)² = 7 - 6√3 + 13 = 20 - 6√3 ≈ 9.607695
    @test tf.f(start_point) ≈ 9.607695 atol=1e-3
    
    # Test minimum
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test all(min_pos .== 0.0)
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    @test tf.f(min_pos) ≈ 0.0 atol=1e-8
    
    # Test gradient at minimum
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-8))
    
    # Test gradient at a point
    test_point = [1.0, 1.0]
    grad = tf.grad(test_point)
    sqrt3 = sqrt(3.0)
    # ∂f/∂x₁ = 14x₁ - 6√3x₂ = 14 - 6√3 ≈ 3.608
    # ∂f/∂x₂ = -6√3x₁ + 26x₂ = -6√3 + 26 ≈ 15.608
    @test grad[1] ≈ 14 - 6*sqrt3 atol=1e-8
    @test grad[2] ≈ -6*sqrt3 + 26 atol=1e-8
    
    # Test bounds
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test all(lb .== -500.0)
    @test all(ub .== 500.0)
    
    # Test NaN/Inf handling
    @test isnan(tf.f([NaN, 1.0]))
    @test isinf(tf.f([Inf, 1.0]))
    
    # Test convexity by checking another point
    test_point2 = [2.0, 1.0]
    # f([2,1]) = 7*4 - 6√3*2*1 + 13*1 = 28 - 12√3 + 13 = 41 - 12√3 ≈ 20.215
    @test tf.f(test_point2) ≈ 41 - 12*sqrt3 atol=1e-3
end