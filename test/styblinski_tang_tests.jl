# test/styblinski_tang_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "styblinski_tang" begin
    tf = STYBLINSKI_TANG_FUNCTION
    @test tf.meta[:name] == "styblinski_tang"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    @test has_property(tf, "non-convex")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Check gradient at minimum (should be approx zeros)
    grad = tf.grad(min_pos)
    @test all(abs.(grad) .< 1e-6)
    
    # Type Stability Check (SHOULD per RULE_DEFAULT_N)
    @code_warntype tf.f(rand(n))
    @code_warntype tf.grad(rand(n))
end