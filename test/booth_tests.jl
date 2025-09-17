# test/booth_tests.jl
# Purpose: Tests for the Booth function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 25 August 2025

using Test
using NonlinearOptimizationTestFunctions: BOOTH_FUNCTION, booth, booth_gradient
using Optim

@testset "Booth Function Tests" begin
    tf = BOOTH_FUNCTION
    n = 2  # Fixed dimension for Booth

    # Metadata tests
    @test tf.meta[:name] == "booth"
    @test tf.meta[:properties] == Set(["bounded", "continuous", "convex", "differentiable", "separable", "unimodal"])
    @test tf.meta[:in_molga_smutnicki_2005] == true

    # Function value tests
    start = tf.meta[:start]()
    @test booth(start) ≈ 74.0 atol=1e-6  # Calculated: (0 + 0 - 7)^2 + (0 + 0 - 5)^2 = 49 + 25 = 74
    min_pos = tf.meta[:min_position]()
    @test booth(min_pos) ≈ tf.meta[:min_value]() atol=1e-6

    # Gradient at minimum
    grad = booth_gradient(min_pos)
    @test ≈(grad, zeros(n), atol=0.01)

    # Dimension checks
    @test_throws ArgumentError booth(Float64[])
    @test_throws ArgumentError booth([1.0])
    @test_throws ArgumentError booth([1.0, 2.0, 3.0])

    # NaN and Inf handling
    @test isnan(booth([NaN, 0.0]))
    @test isnan(booth([0.0, NaN]))
    @test isinf(booth([Inf, 0.0]))
    @test isinf(booth([0.0, Inf]))
    @test isfinite(booth([1e-308, 1e-308]))

    # Optimization tests
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()

        # Optimization from deterministic start
        start = [0.0, 0.0]
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(LBFGS()), Optim.Options(g_abstol=1e-8))
        @test Optim.converged(result)
        @test ≈(Optim.minimum(result), tf.meta[:min_value](), atol=1e-4)
        min_x = Optim.minimizer(result)
        known_minimum = [1.0, 3.0]
        @test norm(min_x - known_minimum) < 0.1
    end
end