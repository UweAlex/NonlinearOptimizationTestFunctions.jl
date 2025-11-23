# test/bohachevsky3_tests.jl
# Purpose: Tests for the Bohachevsky 3 test function.
# Context: Verifies metadata, exact values, edge cases and analytical gradient.
# No optimization tests – these do not belong here!

using Test
using NonlinearOptimizationTestFunctions

@testset "bohachevsky3" begin
    tf = BOHACHEVSKY3_FUNCTION

    # ------------------------------------------------------------------
    # Metadata checks
    # ------------------------------------------------------------------
    @test tf.meta[:name] == "bohachevsky3"
    @test tf.meta[:source] == "Jamil & Yang (2013, p. 11)"

    expected_props = [
        "bounded", "continuous", "differentiable",
        "multimodal", "non-convex", "non-separable"
    ]
    @test issetequal(tf.meta[:properties], expected_props)

    # ------------------------------------------------------------------
    # Meta functions (non-scalable → no argument)
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
    # Exact function values
    # ------------------------------------------------------------------
    @test tf.f(min_pos)             ≈ 0.0      atol = 1e-12
    @test tf.f(start_point)         > min_val + 1.0     # [RULE_START_AWAY_FROM_MIN] validation
    @test norm(tf.grad(min_pos))    < 1e-10             # gradient at minimum ≈ 0
    @test isfinite(tf.f(lb))
    @test isfinite(tf.f(ub))

    # ------------------------------------------------------------------
    # Edge cases
    # ------------------------------------------------------------------
    @test_throws ArgumentError tf.f(Float64[])           # empty
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])     # wrong dimension
    @test isnan(tf.f([NaN, 0.0]))
    @test isnan(tf.f([0.0, NaN]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isinf(tf.f([0.0, Inf]))
    @test isfinite(tf.f(fill(1e-308, 2)))

    # ------------------------------------------------------------------
    # BigFloat high-precision test (optional but recommended)
    # ------------------------------------------------------------------
    x_big = BigFloat.(min_pos)
    @test tf.f(x_big) ≈ BigFloat(min_val) atol = BigFloat("1e-60")
end