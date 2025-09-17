# test/dekkersaarts_tests.jl
# Purpose: Tests for the Dekkers-Aarts test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization for dekkersaarts.jl.
# Last modified: 26 August 2025

using Test
using Optim
using ForwardDiff
using LinearAlgebra
using NonlinearOptimizationTestFunctions: DEKKERSAARTS_FUNCTION, dekkersaarts, dekkersaarts_gradient

@testset "DekkersAarts Tests" begin
    tf = DEKKERSAARTS_FUNCTION
    n = 2  # Fixed dimension for Dekkers-Aarts

    # Metadata tests
    @test tf.meta[:name] == "dekkersaarts"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test tf.meta[:start]() == [0.0, 10.0]
    @test tf.meta[:lb]() == [-20.0, -20.0]
    @test tf.meta[:ub]() == [20.0, 20.0]
    @test tf.meta[:min_value]() ≈ -24776.51834231769 atol=1e-6

    # Function value tests
    start = tf.meta[:start]()
    @test dekkersaarts(start) ≈ -8900.0 atol=1e-6  # f([0, 10]) = -8900.0
    min_pos1 = [0.0, 14.94511215174121]
    min_pos2 = [0.0, -14.94511215174121]
    @test dekkersaarts(min_pos1) ≈ -24776.51834231769 atol=1e-6
    @test dekkersaarts(min_pos2) ≈ -24776.51834231769 atol=1e-6
    @test tf.meta[:min_position]() ≈ min_pos1 atol=1e-6

    # Gradient at minimum
    grad = dekkersaarts_gradient(min_pos1)
    @test isapprox(grad, zeros(n), atol=1e-3)  # Normale Toleranz

    # Edge cases
    @test_throws ArgumentError dekkersaarts(Float64[])
    @test_throws ArgumentError dekkersaarts([1.0])
    @test_throws ArgumentError dekkersaarts([1.0, 2.0, 3.0])
    @test isnan(dekkersaarts([NaN, 0.0]))
    @test isnan(dekkersaarts([0.0, NaN]))
    @test isinf(dekkersaarts([Inf, 0.0]))
    @test isinf(dekkersaarts([0.0, Inf]))
    @test isfinite(dekkersaarts([1e-308, 1e-308]))
    @test isfinite(dekkersaarts(tf.meta[:lb]()))
    @test isfinite(dekkersaarts(tf.meta[:ub]()))

    # Optimization tests with Nelder-Mead
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        minima = [min_pos1, min_pos2]

        # Optimization from near one minimum
        start = min_pos1 .+ 0.01 * randn(n)
        result = optimize(tf.f, start, NelderMead(), Optim.Options(g_tol=1e-8, iterations=10000))
        @test Optim.converged(result)
        @test isapprox(Optim.minimum(result), tf.meta[:min_value](), atol=1e-4)
        @test any(norm(Optim.minimizer(result) - m) < 1e-2 for m in minima)

        # Optimization from start point
        start2 = [0.0, 10.0]
        result2 = optimize(tf.f, start2, NelderMead(), Optim.Options(g_tol=1e-8, iterations=10000))
        @test Optim.converged(result2)
        @test isapprox(Optim.minimum(result2), tf.meta[:min_value](), atol=1e-4)
        @test any(norm(Optim.minimizer(result2) - m) < 1e-2 for m in minima)
    end

    # Gradient comparison tests
    @testset "Gradient Comparison Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        for _ in 1:5
            x = lb .+ (ub .- lb) .* rand(n)
            programmed_grad = dekkersaarts_gradient(x)
            ad_grad = ForwardDiff.gradient(dekkersaarts, x)
            @test isapprox(programmed_grad, ad_grad, atol=1e-3)  # Normale Toleranz
        end
    end
end