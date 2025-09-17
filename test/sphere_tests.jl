# test/sphere_tests.jl
# Purpose: Tests for the Sphere function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, gradients, and optimization.
# Last modified: 16. Juli 2025, 11:36 AM CEST

using Test, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: SPHERE_FUNCTION, sphere, sphere_gradient
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

@testset "Sphere Tests" begin
    tf = SPHERE_FUNCTION
    @test_throws ArgumentError sphere([1.0])
    @test isnan(sphere([NaN, 1.0]))
    @test isinf(sphere([Inf, 1.0]))
    @test isfinite(sphere([1e-308, 1e-308]))
    @test sphere([0.0, 0.0]) ≈ 0.0
    @test sphere([1.0, 1.0]) ≈ 2.0
    @test sphere_gradient([0.0, 0.0]) ≈ [0.0, 0.0]
    @test sphere_gradient([1.0, 1.0]) ≈ [2.0, 2.0]
    @test sphere_gradient([1.0, 1.0]) ≈ finite_difference_gradient(sphere, [1.0, 1.0]) atol=1e-6
    x = tf.meta[:start](2)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ sphere_gradient(x) atol=1e-6
    @test tf.meta[:name] == "sphere"
    @test tf.meta[:start](2) == [0.0, 0.0]
    @test tf.meta[:min_position](2) == [0.0, 0.0]
    @test tf.meta[:min_value](2) ≈ 0.0
    @test tf.meta[:lb](2) == [-5.12, -5.12]
    @test tf.meta[:ub](2) == [5.12, 5.12]
    @testset "Optimization Tests" begin
        result = optimize(tf.f, tf.gradient!, tf.meta[:start](2), LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) < 1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](2) atol=1e-3
    end
    result_n10 = optimize(tf.f, tf.gradient!, tf.meta[:start](10), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.minimum(result_n10) < 1e-5
    @test Optim.minimizer(result_n10) ≈ tf.meta[:min_position](10) atol=1e-3
    result_n100 = optimize(tf.f, tf.gradient!, tf.meta[:start](100), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.minimum(result_n100) < 1e-5
    @test Optim.minimizer(result_n100) ≈ tf.meta[:min_position](100) atol=1e-3
end