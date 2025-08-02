# test/ackley_tests.jl
# Purpose: Tests for the Ackley function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, gradients, and optimization.
# Last modified: 16. Juli 2025, 13:00 PM CEST

using Test, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: ACKLEY_FUNCTION, ackley, ackley_gradient
using Optim

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

@testset "Ackley Tests" begin
    tf = ACKLEY_FUNCTION
    @test_throws ArgumentError ackley([])
    @test isnan(ackley([NaN]))
    @test isinf(ackley([Inf]))
    @test isfinite(ackley([1e-308]))
    @test ackley([0.0]) ≈ 0.0 atol=1e-6
    @test ackley([0.0, 0.0]) ≈ 0.0 atol=1e-6
    @test ackley([1.0, 1.0]) ≈ 3.6253849384403627 atol=1e-6
    @test ackley_gradient([0.0]) ≈ [0.0] atol=1e-6
    @test ackley_gradient([1.0, 1.0]) ≈ finite_difference_gradient(ackley, [1.0, 1.0]) atol=1e-6
    x = tf.meta[:start](2)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ ackley_gradient(x) atol=1e-6
    @test tf.meta[:name] == "ackley"
    @test tf.meta[:start](1) == [1.0]
    @test tf.meta[:min_position](1) == [0.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](1) == [-5.0]
    @test tf.meta[:ub](1) == [5.0]
    @test tf.meta[:lb](2, bounds="benchmark") == [-32.768, -32.768]
    @test tf.meta[:ub](2, bounds="benchmark") == [32.768, 32.768]
    @testset "Optimization Tests" begin
        result = optimize(tf.f, tf.gradient!, tf.meta[:start](2), LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) < 1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](2) atol=1e-3
    end
end