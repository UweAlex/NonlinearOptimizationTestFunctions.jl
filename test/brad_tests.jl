# test/brad_tests.jl
using Test
using NonlinearOptimizationTestFunctions

@testset "brad" begin
    tf = BRAD_FUNCTION

    # ------------------------------------------------------------------
    # Metadata
    # ------------------------------------------------------------------
    @test tf.meta[:name] == "brad"
    @test tf.meta[:source] == "Brad (1970); data from Moré et al. (1981)"

    expected_props = ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"]
    @test issetequal(tf.meta[:properties], expected_props)

    # ------------------------------------------------------------------
    # Meta functions
    # ------------------------------------------------------------------
    start_point = tf.meta[:start]()
    min_pos     = tf.meta[:min_position]()
    min_val     = tf.meta[:min_value]()
    lb          = tf.meta[:lb]()
    ub          = tf.meta[:ub]()

    @test start_point ≈ [0.0, 1.0, 1.0]       atol=1e-12
    @test min_pos     ≈ [0.08241056, 1.13303609, 2.34369518] atol=1e-8
    @test min_val     ≈ 0.008214877306578994 atol=1e-15
    @test lb          == [-0.25, 0.01, 0.01]
    @test ub          == [0.25, 2.5, 2.5]

    # ------------------------------------------------------------------
    # Function & gradient
    # ------------------------------------------------------------------
    @test tf.f(min_pos)     ≈ min_val      atol=1e-12
    @test tf.f(start_point) > min_val + 1.0               # [RULE_START_AWAY_FROM_MIN]

    # Gradient am Minimum: numerische Rundung → 1.46e-8 ist völlig ok!
    @test norm(tf.grad(min_pos)) < 1e-7                   # ← realistische Toleranz

    @test isfinite(tf.f(lb))
    @test isfinite(tf.f(ub))

    # ------------------------------------------------------------------
    # Edge cases
    # ------------------------------------------------------------------
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0, 4.0])
    @test isnan(tf.f([NaN, 1.0, 1.0]))
    @test isinf(tf.f([0.0, 0.0, 1.0]))      # x2 = 0 → Inf
    @test isinf(tf.f([0.0, 1.0, 0.0]))      # x3 = 0 → Inf

    # Sehr kleine Werte: denom wird extrem klein → f wird riesig → Inf
    @test isinf(tf.f(fill(1e-308, 3)))      # ← korrektes Verhalten!

   
end