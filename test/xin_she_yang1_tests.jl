# test/xin_she_yang1_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "xin_she_yang1" begin
    tf = XIN_SHE_YANG1_FUNCTION
    @test tf.meta[:name] == "xin_she_yang1"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "has_noise")
    @test has_property(tf, "scalable")
    @test has_property(tf, "separable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "partially differentiable")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test tf.f(start_point) > 0  # Terms/Noise ensure >0 [FIX: no atol for >]
    
    min_pos = tf.meta[:min_position](n)
    f_min = tf.f(min_pos)
    @test f_min == 0  # Exact 0 at zeros (deterministic)
    
    # Noise validation: Multiple evals at non-min (range >0)
    vals = [tf.f([1.0]) for _ in 1:10]  # n=1 for simplicity
    @test all(v > 0 for v in vals)  # Noise >0
    @test maximum(vals) - minimum(vals) > 0.1  # Variability from noise
    
    # Gradient at min (should be [0,0,...,0], since at 0)
    grad_min = tf.grad(min_pos)
    @test all(isapprox.(grad_min, 0, atol=1e-8))
    
    # Optional: High-Prec-Validierung [RULE_HIGH_PREC_SUPPORT]
    # using BigFloat; setprecision(256); @test tf.f(BigFloat.(min_pos)) == BigFloat(0) atol=BigFloat("1e-15")
end