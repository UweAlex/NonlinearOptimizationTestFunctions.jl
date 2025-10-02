# test/becker_lago_tests.jl
# Purpose: Tests for the Becker and Lago test function.
# Last modified: October 01, 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "becker_lago" begin
    tf = BECKER_LAGO_FUNCTION

    @test tf.meta[:name] == "becker_lago"
    @test has_property(tf, "continuous")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    @test !has_property(tf, "scalable")
    @test !has_property(tf, "differentiable")  # Due to absolute value terms
    @test tf.meta[:properties_source] == "Price (1977) via Jamil & Yang (2013, No. 96)"
    @test length(tf.meta[:properties]) == 4

    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    @test isnan(tf.f([NaN, 1.0]))
    @test isinf(tf.f([Inf, 1.0]))

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 50.0 atol=1e-3  # (|0|-5)^2 + (|0|-5)^2 = 50

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [5.0, 5.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ 0.0 atol=1e-8
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    # Test other minima
    @test tf.f([5.0, -5.0]) ≈ 0.0 atol=1e-8
    @test tf.f([-5.0, 5.0]) ≈ 0.0 atol=1e-8
    @test tf.f([-5.0, -5.0]) ≈ 0.0 atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-10.0, -10.0]
    @test ub ≈ [10.0, 10.0]

    # Extra point
    test_pt = [0.5, 0.5]
    f_test = tf.f(test_pt)  # (|0.5|-5)^2 + (|0.5|-5)^2 = 40.5
    @test f_test ≈ 40.5 atol=1e-3

    # Gradient test (outside non-differentiable points)
    grad_analytic = tf.grad([0.5, 0.5])
    grad_fd = ForwardDiff.gradient(tf.f, [0.5, 0.5])
    @test grad_analytic ≈ grad_fd atol=1e-8  # 2*(0.5-5)*sign(0.5) = 2*(-4.5)*1 = -9
end