# test/salomon_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "salomon" begin
    tf = SALOMON_FUNCTION
    @test tf.meta[:name] == "salomon"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    
    n = tf.meta[:default_n]  # Use default_n for standard tests
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Example check
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(min_pos .== 0)
    
    # Standard minimum check (no noise)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Check that min_value call works (constant, ignores n)
    @test tf.meta[:min_value](n) == 0.0
    
    # Gradient test at minimum (zeros)
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(n), atol=1e-8))
    
    # Extra: Check bounds
    lb = tf.meta[:lb](n)
    ub = tf.meta[:ub](n)
    @test all(lb .== -100.0)
    @test all(ub .== 100.0)
end