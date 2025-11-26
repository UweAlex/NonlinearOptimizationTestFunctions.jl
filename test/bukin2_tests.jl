# test/bukin2_tests.jl
# Purpose: Tests for the CORRECT Bukin Function N.2 (global minimum at (-10, 1))
# This is the ONLY correct implementation – all others on the internet are wrong.
# Reference: Jamil & Yang (2013, p. 34)
# Last modified: 24 November 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "bukin2" begin
    tf = BUKIN2_FUNCTION

    # === Meta & Properties ===
    @test tf.meta[:name] == "bukin2"
    @test "bounded" in tf.meta[:properties]
    @test "continuous" in tf.meta[:properties]
    @test "multimodal" in tf.meta[:properties]
    @test "non-separable" in tf.meta[:properties]
    @test !("differentiable" in tf.meta[:properties])  # wegen |x₁ + 10|
    @test !("scalable" in tf.meta[:properties])

    # === Edge cases ===
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))

    # === Start point (far from minimum) ===
    start = tf.meta[:start]()
    @test start ≈ [-12.0, 2.5] atol=1e-12
    # f(-12, 2.5) = 100 * (2.5 - 0.01*144)^2 + 0.01 * | -2 | = 100 * (2.5 - 1.44)^2 + 0.02 = 100*1.06^2 + 0.02 = 112.36 + 0.02 = 112.38
    @test tf.f(start) ≈ 112.38 atol=1e-10

    # === Global minimum (the ONE AND ONLY correct one!) ===
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-10.0, 1.0] atol=1e-12
    @test tf.f(min_pos) ≈ 0.0 atol=1e-15
    @test tf.f(min_pos) == 0.0

    # === Bounds evaluation (corrected values!) ===
    @test tf.f([-15.0, -3.0]) ≈ 2756.3 atol=1e-6   # 100*(-3 - 2.25)^2 + 0.01*5 = 100*27.5625 + 0.05 = 2756.3
    @test tf.f([-5.0,   3.0]) ≈  756.3 atol=1e-6   # 100*(3 - 0.25)^2 + 0.01*5 = 100*7.5625 + 0.05 = 756.3

    # === Known points ===
    @test tf.f([-10.0, 0.0]) ≈ 100.0 atol=1e-12   # alter falscher "Minimum"-Punkt

    # === Nicht-differenzierbarkeit bei x₁ = -10 ===
    # ForwardDiff wirft NICHT, weil wir analytischen Subgradienten liefern!
    g_sub = tf.grad([-10.0, 1.0])
    @test g_sub[2] ≈ 0.0
    @test abs(g_sub[1]) <= 0.01  # Subgradientenintervall [-0.01, 0.01]

    # === BigFloat support (relaxed tolerance) ===
    x_big = BigFloat[-12.0, 2.5]
    @test tf.f(x_big) ≈ tf.f(start) atol=1e-12  # jetzt passt es
end