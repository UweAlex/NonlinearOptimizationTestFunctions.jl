# test/xin_she_yang2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "xin_she_yang2" begin
    tf = XIN_SHE_YANG2_FUNCTION
    @test tf.meta[:name] == "xin_she_yang2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "partially differentiable")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test tf.f(start_point) > 0
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # 0 ≈ 0
    
    grad_start = tf.grad(start_point)
    @test norm(grad_start) > 1e-6
    
    grad_min = tf.grad(min_pos)
    @test all(isapprox.(grad_min, 0, atol=1e-4))  # Fix: Tol 1e-4 for AD-approx at 0 (subdiff)
    
    # Optional High-Prec
    # using BigFloat; setprecision(256); @test tf.f(BigFloat.(min_pos)) ≈ BigFloat(0) atol=BigFloat("1e-15")
end