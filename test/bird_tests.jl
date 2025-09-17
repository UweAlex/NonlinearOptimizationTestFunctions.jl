# test/bird_tests.jl
# Purpose: Tests for the Bird function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 14 September 2025

using Test
using NonlinearOptimizationTestFunctions: BIRD_FUNCTION, bird, bird_gradient
using Optim

@testset "Bird Function Tests" begin
    tf = BIRD_FUNCTION
    n = 2  # Fixed dimension for Bird

    # Metadata tests
    @test tf.meta[:name] == "bird"
    @test tf.meta[:properties] == Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"])

    # Function value tests
    start = tf.meta[:start]()
    @test bird(start) ≈ exp(1) atol=1e-10
    min_pos = tf.meta[:min_position]()
    @test isapprox(bird(min_pos), tf.meta[:min_value](), atol=1e-10)

    # Gradient at minimum
    grad = bird_gradient(min_pos)
    @test isapprox(grad, zeros(n), atol=0.01)

    # Dimension checks
    @test_throws ArgumentError bird(Float64[])
    @test_throws ArgumentError bird([1.0])
    @test_throws ArgumentError bird([1.0, 2.0, 3.0])

    # NaN and Inf handling
    @test isnan(bird([NaN, 0.0]))
    @test isnan(bird([0.0, NaN]))
    @test isinf(bird([Inf, 0.0]))
    @test isinf(bird([0.0, Inf]))
    @test isfinite(bird([1e-308, 1e-308]))

    # Optimization tests
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()

        # Optimization from start near one minimum
        start = [4.7010558160187405, 3.152946019601391]
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(LBFGS()), Optim.Options(g_abstol=1e-8))
        @test Optim.converged(result)
        @test isapprox(Optim.minimum(result), tf.meta[:min_value](), atol=1e-3)
        min_x = Optim.minimizer(result)
        known_minima = [[4.7010558160187405, 3.152946019601391], [-1.5821421720550115, -3.1302467996354306]]
        dists = [norm(min_x - m) for m in known_minima]
        @test minimum(dists) < 0.01

        # Optimization from start near the other minimum
        start2 = [-1.5821421720550115, -3.1302467996354306]
        result_local = optimize(tf.f, tf.gradient!, lb, ub, start2, Fminbox(LBFGS()), Optim.Options(g_abstol=1e-8))
        @test Optim.converged(result_local)
        @test isapprox(Optim.minimum(result_local), tf.meta[:min_value](), atol=1e-3)
        min_x_local = Optim.minimizer(result_local)
        dists_local = [norm(min_x_local - m) for m in known_minima]
        @test minimum(dists_local) < 0.01
    end
end