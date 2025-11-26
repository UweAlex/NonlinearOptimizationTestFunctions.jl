# test/braninrcos2_tests.jl
# Purpose: Tests for Branin RCOS 2 – minimal, robust, fully compliant
# Last modified: 24 November 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "braninrcos2" begin
    tf = BRANINRCOS2_FUNCTION

    # === Meta & Properties ===
    @test tf.meta[:name] == "braninrcos2"
    @test all(p -> has_property(tf, p), ["bounded", "continuous", "differentiable",
                                         "multimodal", "non-separable"])
    @test !has_property(tf, "scalable")

    # === Edge cases ===
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))

    # === Start point (far from minimum – [RULE_START_AWAY_FROM_MIN]) ===
    start_pt = tf.meta[:start]()
    @test start_pt ≈ [0.0, 10.0] atol=1e-12
    @test tf.f(start_pt) ≈ -11.183376828019092 atol=1e-10

    # === Global minimum (high precision) ===
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-3.1721041516027824, 12.58567479697034] atol=1e-12
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-10

    # === Bounds ===
    @test tf.meta[:lb]() ≈ [-5.0, -5.0]
    @test tf.meta[:ub]() ≈ [15.0, 15.0]

    # === Known evaluation points (nur verifizierte Werte!) ===
    @test tf.f([0.0, 0.0]) ≈ 46.0          atol=1e-12
    @test tf.f([1.0, 1.0]) ≈ 25.594        atol=1e-3
    @test tf.f([5.0, 5.0]) ≈ 26.936819575  atol=1e-8

    # === Gradient correctness (analytical vs ForwardDiff) ===
    g_ana = tf.grad(start_pt)
    g_fd  = ForwardDiff.gradient(tf.f, start_pt)
    @test g_ana ≈ g_fd atol=1e-10

    # === BigFloat support (relaxed tolerance due to log/cos) ===
    x_big = BigFloat[0.0, 10.0]
    @test tf.f(x_big) ≈ tf.f(start_pt) atol=1e-14   # Vergleich mit Double reicht völlig aus
end