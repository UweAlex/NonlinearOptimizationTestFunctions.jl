# test/bohachevsky1_tests.jl
using Test
using NonlinearOptimizationTestFunctions: BOHACHEVSKY1_FUNCTION, bohachevsky1

@testset "Bohachevsky1 Tests" begin
    tf = BOHACHEVSKY1_FUNCTION
    n = tf.meta[:default_n]

    # Metadata
    @test tf.meta[:name] == "bohachevsky1"
    @test Set(tf.meta[:properties]) == Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex", "scalable", "separable"])

    # Edge cases
    @test_throws ArgumentError bohachevsky1(Float64[])
    @test_throws ArgumentError bohachevsky1([1.0])  # n=1
    @test isnan(bohachevsky1([NaN, 0.0]))
    @test isinf(bohachevsky1([Inf, 0.0]))

    # Start point
    start = tf.meta[:start](n)
    @test start ≈ fill(1.0, n)
    @test bohachevsky1(start) ≈ 3.6 atol=1e-6  # für n=2

    # Minimum
    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ zeros(n)
    @test bohachevsky1(min_pos) ≈ 0.0 atol=1e-10

    # Bounds
    @test tf.meta[:lb](n) == fill(-100.0, n)
    @test tf.meta[:ub](n) == fill(100.0, n)

    # Extra point n=3
    @test bohachevsky1([1.0, 1.0, 1.0]) ≈ 7.2 atol=1e-6

    # Start away from min
    @test tf.f(start) > tf.meta[:min_value](n) + 1e-3
end