# test/shubert_noisy_tests.jl
using Test, NonlinearOptimizationTestFunctions
using ForwardDiff

@testset "shubert_noisy" begin
    tf = SHUBERT_NOISY_FUNCTION
    
    # [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/shubert_noisy.jl")[1:end-3]
    
    # [RULE_DEFAULT_N]
    @test haskey(tf.meta, :default_n)
    @test tf.meta[:default_n] >= 2
    n = tf.meta[:default_n]
    
    # [VALID_PROPERTIES]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "has_noise")
    
    # Start
    start_pt = tf.meta[:start](n)
    @test length(start_pt) == n
    @test all(isapprox.(start_pt, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    
    # Minimum
    min_pos = tf.meta[:min_position](n)
    f_vals = [tf.f(min_pos) for _ in 1:100]  # [RULE_NOISE_HANDLING]
    min_val = tf.meta[:min_value](n)  # -186.7309
    @test all(v >= min_val - 3 * 0.1 && v <= min_val + 3 * 0.1 for v in f_vals)  # ±3σ-Bereich
    @test mean(f_vals) ≈ min_val atol=0.1  # Erwartungswert ≈ deterministisches Minimum
    
    # Zusätzliches Minimum (aus Liste der 18 Minima)
    min_pos_alt = [-7.0835, 4.8580]
    f_vals_alt = [tf.f(min_pos_alt) for _ in 1:100]
    @test all(v >= min_val - 3 * 0.1 && v <= min_val + 3 * 0.1 for v in f_vals_alt)
    
    # Gradient
    grad = tf.grad(start_pt)  # [RULE_TESTFUNCTION_FIELDS]
    @test length(grad) == n
    grad_fd = ForwardDiff.gradient(tf.f, start_pt)
    @test all(isapprox.(grad, grad_fd, atol=1e-6))  # [RULE_TEST_SYNTAX]
    
    # Type-Stability
    @test @inferred(tf.f(rand(n))) isa Real
    
    # Fehlerfälle
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN]))
    @test isinf(tf.f([Inf]))
end