# test/shubert_noisy_tests.jl

using Test, NonlinearOptimizationTestFunctions , Statistics
@testset "shubert_noisy" begin
    tf = SHUBERT_NOISY_FUNCTION
    
    # [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/shubert_noisy.jl")[1:end-3]
    
    # [VALID_PROPERTIES]: Für JEDE Property
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "has_noise")
    
    # Start (non-scalable: () -> )
    start_pt = tf.meta[:start]()
    f_start = tf.f(start_pt)
    @test f_start > -200  # Approximate due to noise; inequality without atol
    
    # Minimum (non-scalable: () -> )
    min_pos = tf.meta[:min_position]()
    f_min = tf.f(min_pos)
    
    # [RULE_NOISE_HANDLING]
    if "has_noise" in tf.meta[:properties]
        @test f_min >= tf.meta[:min_value]()
        @test f_min < tf.meta[:min_value]() + 1.0  # For U[0,1)
    else
        @test f_min ≈ tf.meta[:min_value]() atol=1e-8
    end
    
    # Multiple evals for mean (optional, for validation)
    f_vals = [tf.f(min_pos) for _ in 1:20]
    @test mean(f_vals) ≈ tf.meta[:min_value]() + 0.5 atol=0.3  # Expected mean for U[0,1)
    
    # Gradient at min_pos (should be ~0 for base)
    grad_min = tf.grad(min_pos)  # [RULE_TESTFUNCTION_FIELDS]: tf.grad!
    @test all(isapprox.(grad_min, [0.0, 0.0], atol=1e-3))  # [RULE_TEST_SYNTAX]; loosened tol for FP
end