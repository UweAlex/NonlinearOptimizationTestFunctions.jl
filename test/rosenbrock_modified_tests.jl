# test/rosenbrock_modified_tests.jl

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "rosenbrock_modified" begin
    tf = ROSENBROCK_MODIFIED_FUNCTION

    @test tf.meta[:name] == "rosenbrock_modified"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "deceptive")
    @test has_property(tf, "controversial")
    @test has_property(tf, "ill-conditioned")
    @test length(tf.meta[:properties]) == 9
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol = 1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 75.0 atol = 1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-0.90955374, -0.95057172] atol = 1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol = 1e-10  # Precise value, tight atol

    lb = tf.meta[:lb]()
    @test lb ≈ [-2.0, -2.0]
    ub = tf.meta[:ub]()
    @test ub ≈ [2.0, 2.0]

    # Extra point: [1.0, 1.0] (local min)
    test_pt = [1.0, 1.0]
    @test tf.f(test_pt) ≈ 74.0 atol = 1e-3

    # Gradient at minimum ≈ zero
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-6))

    # AD gradient match
    ad_grad = ForwardDiff.gradient(tf.f, min_pos)
    @test ad_grad ≈ grad_at_min atol = 1e-8
end