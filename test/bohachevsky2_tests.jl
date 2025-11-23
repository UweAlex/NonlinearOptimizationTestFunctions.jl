# test/bohachevsky2_tests.jl
# Purpose: Tests for the Bohachevsky 2 test function.
# Context: Verifies metadata, exact function values, edge cases and analytical gradient.
# NO OPTIMIZATION TESTS – these do not belong here!

using Test
using NonlinearOptimizationTestFunctions

@testset "bohachevsky2" begin
    tf = BOHACHEVSKY2_FUNCTION

    # ------------------------------------------------------------------
    # Metadata ([RULE_NAME_CONSISTENCY], [RULE_PROPERTIES_SOURCE])
    # ------------------------------------------------------------------
    @test tf.meta[:name] == "bohachevsky2"
    @test tf.meta[:source] == "Jamil & Yang (2013, p. 11)"

    expected_props = [
        "bounded", "continuous", "differentiable",
        "multimodal", "non-convex", "non-separable"
    ]
    @test issetequal(tf.meta[:properties], expected_props)

    # ------------------------------------------------------------------
    # Meta-Funktionen (non-scalable → Aufruf ohne n)
    # ------------------------------------------------------------------
    start_point = tf.meta[:start]()
    min_pos     = tf.meta[:min_position]()
    min_val     = tf.meta[:min_value]()
    lb          = tf.meta[:lb]()
    ub          = tf.meta[:ub]()

    @test start_point == [50.0, 50.0]          # [RULE_START_AWAY_FROM_MIN]
    @test min_pos     == [0.0, 0.0]
    @test min_val     == 0.0
    @test lb          == [-100.0, -100.0]
    @test ub          == [100.0, 100.0]

    # ------------------------------------------------------------------
    # Exakte Funktionswerte
    # ------------------------------------------------------------------
    @test tf.f(min_pos)             ≈ 0.0      atol = 1e-12
    @test tf.f(start_point)         > min_val + 1.0   # [RULE_START_AWAY_FROM_MIN] Validierung
    @test isfinite(tf.f(lb))
    @test isfinite(tf.f(ub))

    # Gradient am globalen Minimum ≈ 0
    @test norm(tf.grad(min_pos))    < 1e-10

    # ------------------------------------------------------------------
    # Edge Cases ([RULE_ERROR_HANDLING])
    # ------------------------------------------------------------------
    @test_throws ArgumentError tf.f(Float64[])           # leer
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])     # falsche Dimension
    @test isnan(tf.f([NaN, 0.0]))
    @test isnan(tf.f([0.0, NaN]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isinf(tf.f([0.0, Inf]))
    @test isfinite(tf.f(fill(1e-308, 2)))

    # ------------------------------------------------------------------
    # Optional: High-Precision Test (BigFloat)
    # ------------------------------------------------------------------
    x_big = BigFloat.(min_pos)
    @test tf.f(x_big) ≈ BigFloat(min_val) atol = BigFloat("1e-60")
end