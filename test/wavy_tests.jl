# test/wavy_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "wavy" begin
    tf = WAVY_FUNCTION
    @test tf.meta[:name] == "wavy"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    
    n = tf.meta[:default_n]  # [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 1.0)  # Check neutral start
    
    @test tf.f(start_point) ≈ 1.509 atol=1e-3  # f(fill(1.0,2)) ≈1.5089 for n=2 [RULE_ATOL]
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8  # 0.0
    
    # Extra: Check at non-zero point (e.g., π/2)
    test_point = fill(π/2, n)
    term = cos(5π) * exp(-(π/2)^2 / 2)  # ≈ -0.2913
    expected_f = 1 - term  # 1 - (-0.2913) ≈1.2913 (corrected sign)
    @test tf.f(test_point) ≈ expected_f atol=1e-3
end