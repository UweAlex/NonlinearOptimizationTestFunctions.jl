# test/bird_tests.jl
using Test, Optim
using NonlinearOptimizationTestFunctions: BIRD_FUNCTION, bird, bird_gradient

@testset "Bird Function Tests" begin
    tf = BIRD_FUNCTION

    # Metadata
    @test tf.meta[:name] == "bird"
    @test Set(tf.meta[:properties]) == Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"])

    # Start away from min
    start = tf.meta[:start]()
    @test tf.f(start) > tf.meta[:min_value]() + 1e-3

    # Minimum
    min_pos = tf.meta[:min_position]()
    @test bird(min_pos) ≈ tf.meta[:min_value]() atol=1e-10

  
    # Edge cases
    @test_throws ArgumentError bird(Float64[])
    @test isnan(bird([NaN, 0.0]))
    @test isinf(bird([Inf, 0.0]))
    @test isfinite(bird([1e-308, 1e-308]))
    @test_throws ArgumentError bird([1.0])
    @test_throws ArgumentError bird([1.0, 2.0, 3.0])
end