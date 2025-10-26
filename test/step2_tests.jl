# test/step2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "step2" begin
    tf = STEP2_FUNCTION
    @test tf.meta[:name] == "step2"
    @test has_property(tf, "partially differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "bounded")
    @test has_property(tf, "non-convex")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Extra: Check another point in the minimum basin
    min_pos_alt = fill(0.499, n)
    @test tf.f(min_pos_alt) ≈ 0.0 atol=1e-8
    
    # Check gradient (should be zeros)
    grad = tf.grad(min_pos)
    @test all(grad .== 0)
    
    # Type Stability Check (SHOULD per RULE_DEFAULT_N)
    @code_warntype tf.f(rand(n))
    @code_warntype tf.grad(rand(n))
end