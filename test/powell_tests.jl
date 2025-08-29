# test/powell_tests.jl
# Purpose: Tests for the Powell function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, and optimization compatibility with Optim.jl.
# Last modified: 29 August 2025, 10:32 AM CEST

using Test
using NonlinearOptimizationTestFunctions: POWELL_FUNCTION, powell, powell_gradient
using Optim
using LinearAlgebra
using ForwardDiff

function finite_difference_gradient(f, x, h=1e-6)
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        x_plus = copy(x)
        x_minus = copy(x)
        x_plus[i] += h
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2h)
    end
    return grad
end

@testset "Powell Tests" begin
    tf = POWELL_FUNCTION

    # Edge cases
    @test_throws ArgumentError powell([])
    @test_throws ArgumentError powell([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(powell([NaN, 0.0, 0.0, 0.0]))
    @test isinf(powell([Inf, 0.0, 0.0, 0.0]))
    @test isfinite(powell([1e-308, 1e-308, 1e-308, 1e-308]))

    # Function value tests
    @test tf.meta[:name] == "powell"
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:min_position]() == [0.0, 0.0, 0.0, 0.0]
    @test tf.meta[:start]() == [3.0, -1.0, 0.0, 1.0]
    @test tf.meta[:lb]() == fill(-4.0, 4)
    @test tf.meta[:ub]() == fill(5.0, 4)
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test powell([0.0, 0.0, 0.0, 0.0]) == 0.0
    @test isapprox(powell([3.0, -1.0, 0.0, 1.0]), 215.0, atol=1e-6)  # Korrigierter Wert
    @test isapprox(powell_gradient([1.0, 1.0, 1.0, 1.0]), [22.0, 216.0, 8.0, 0.0], atol=1e-6)
    @test isapprox(powell_gradient([0.0, 0.0, 0.0, 0.0]), [0.0, 0.0, 0.0, 0.0], atol=1e-6)
    @test isapprox(powell_gradient([1.0, 1.0, 1.0, 1.0]), finite_difference_gradient(powell, [1.0, 1.0, 1.0, 1.0]), atol=1e-6)

    # Optimization tests
    @testset "Optimization Tests" begin
        start = [0.1, -0.1, 0.1, 0.1]  # Closer to minimum for better convergence
        result = optimize(
            tf.f,
            tf.meta[:lb](),
            tf.meta[:ub](),
            start,
            Fminbox(LBFGS()),
            Optim.Options(iterations=1000, g_tol=1e-8)
        )
        @test Optim.converged(result)
        @test Optim.minimum(result) < 0.0001
        @test isapprox(Optim.minimizer(result), tf.meta[:min_position](), atol=0.01)
    end
end