# test/price4_tests.jl
# Purpose: Tests for the Price 4 test function.
# Last modified: October 01, 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "price4" begin
    tf = PRICE4_FUNCTION

    @test tf.meta[:name] == "price4"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    @test !has_property(tf, "scalable")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    @test isnan(tf.f([NaN, 1.0]))
    @test isinf(tf.f([Inf, 1.0]))

    start_point = tf.meta[:start]()
    @test start_point ≈ [1.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 37.0 atol=1e-3  # (2*1^3*1 - 1^3)^2 + (6*1 - 1^2 + 1)^2 = 1 + 36 = 37

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ 0.0 atol=1e-8
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    # Extra minimum
    extra_min = [2.0, 4.0]
    @test tf.f(extra_min) ≈ 0.0 atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-500.0, -500.0]
    @test ub ≈ [500.0, 500.0]

    # Extra point
    test_pt = [0.5, 0.5]
    f_test = tf.f(test_pt)  # (2*0.5^3*0.5 - 0.5^3)^2 + (6*0.5 - 0.5^2 + 0.5)^2 = (0.125 - 0.125)^2 + (3 - 0.25 + 0.5)^2 = 0 + 3.25^2 ≈ 10.5625
    @test f_test ≈ 10.5625 atol=1e-3

    # Gradient test
    grad_analytic = tf.grad(start_point)
    grad_fd = ForwardDiff.gradient(tf.f, start_point)
    @test grad_analytic ≈ grad_fd atol=1e-8
end