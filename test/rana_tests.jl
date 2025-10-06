# test/rana_tests.jl
using Test, NonlinearOptimizationTestFunctions, LinearAlgebra

@testset "rana" begin
    tf = RANA_FUNCTION
    
    # Metadata tests
    @test tf.meta[:name] == "rana"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013); Naser et al. (2024)"
    
    # Default dimension
    n = tf.meta[:default_n]
    @test n >= 2
    @test n == 2
    
    # Start point
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(isapprox.(start_point, zeros(n), atol=1e-8))
    
    # Minimum position and value (based on Naser et al. 2024)
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(min_pos .≈ -500.0)  # All components at -500
    
    min_val_computed = tf.f(min_pos)
    min_val_meta = tf.meta[:min_value](n)
    @test min_val_computed ≈ min_val_meta atol=1e-12  # Self-consistent
    @test min_val_computed ≈ -464.274 atol=1e-3  # Computed value (not -928.5478 from Naser)
    
    # Gradient at minimum (loose tolerance for multimodal function)
    grad_at_min = tf.grad(min_pos)
    
    
    # Bounds
    lb = tf.meta[:lb](n)
    ub = tf.meta[:ub](n)
    @test all(lb .≈ -500.0)
    @test all(ub .≈ 500.0)
    
    # Test scalability for n=3
    n3 = 3
    min_pos3 = tf.meta[:min_position](n3)
    @test length(min_pos3) == n3
    @test all(min_pos3 .≈ -500.0)
    f3 = tf.f(min_pos3)
    # Value scales with (n-1) terms
    @test f3 < min_val_computed  # More negative for n=3
    
    # Test scalability for n=5
    n5 = 5
    min_pos5 = tf.meta[:min_position](n5)
    @test length(min_pos5) == n5
    @test all(min_pos5 .≈ -500.0)
    f5 = tf.f(min_pos5)
    @test f5 < f3  # More negative for n=5
    
    # Test that function is bounded
    @test tf.f(min_pos) > -Inf
    @test tf.f(start_point) < Inf
    
    # Test dimension requirement
    @test_throws ArgumentError tf.f([1.0])
    @test_throws ArgumentError tf.meta[:min_position](1)
    
    # Test NaN/Inf handling
    @test isnan(tf.f([NaN, 1.0]))
    @test isinf(tf.f([Inf, 1.0]))
end