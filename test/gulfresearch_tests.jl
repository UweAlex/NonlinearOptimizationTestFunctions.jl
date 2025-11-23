# test/gulfresearch_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "gulfresearch" begin
    tf = GULFRESEARCH_FUNCTION

    @test tf.meta[:name] == "gulfresearch"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])

    # ---------- Neuer, regelkonformer Startpunkt ----------
    start_point = tf.meta[:start]()
    @test start_point ≈ [30.0, 10.0, 2.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 32.833 atol=1e-3   # exakt berechnet: ~32.832986

    # ---------- Globales Minimum ----------
    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [50.0, 25.0, 1.5] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8   # ≈ 0.0

    # ---------- Bounds ----------
    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [0.1, 0.0, 0.0] atol=1e-10
    @test ub ≈ [100.0, 25.6, 5.0] atol=1e-10

    # ---------- Extra Testpunkt (optional, aber sinnvoll) ----------
    @test tf.f([10.0, 10.0, 1.0]) ≈ 22.47 atol=1e-3
end