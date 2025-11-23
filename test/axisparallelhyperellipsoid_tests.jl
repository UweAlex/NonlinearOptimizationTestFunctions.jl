# test/axisparallelhyperellipsoid_tests.jl
# Purpose: Tests for the Axis Parallel Hyper-Ellipsoid function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: November 17, 2025

using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: AXISPARALLELHYPERELLIPSOID_FUNCTION, axisparallelhyperellipsoid, axisparallelhyperellipsoid_gradient

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

@testset "AxisParallelHyperEllipsoid Tests" begin
    tf = AXISPARALLELHYPERELLIPSOID_FUNCTION
    n = tf.meta[:default_n]

    # Metadata
    @test tf.meta[:name] == "axisparallelhyperellipsoid"
    @test Set(tf.meta[:properties]) == Set(["convex", "differentiable", "separable", "scalable", "continuous"])

    # Edge Cases
    @test_throws ArgumentError axisparallelhyperellipsoid(Float64[])
    @test isnan(axisparallelhyperellipsoid([NaN]))
    @test isinf(axisparallelhyperellipsoid([Inf]))
    @test isfinite(axisparallelhyperellipsoid(fill(1e-308, n)))

    # Function Values
    @test axisparallelhyperellipsoid(tf.meta[:min_position](n)) ≈ 0.0 atol=1e-6
    @test axisparallelhyperellipsoid(tf.meta[:start](n)) ≈ sum(i * 1^2 for i in 1:n) atol=1e-6  # n(n+1)/2

    # Gradient
    @test axisparallelhyperellipsoid_gradient(tf.meta[:min_position](n)) ≈ zeros(n) atol=1e-6
    @test axisparallelhyperellipsoid_gradient(tf.meta[:start](n)) ≈ [2*i*1 for i in 1:n] atol=1e-6
    @test axisparallelhyperellipsoid_gradient(tf.meta[:start](n)) ≈ finite_difference_gradient(axisparallelhyperellipsoid, tf.meta[:start](n)) atol=1e-6

    # In-place gradient
    x = tf.meta[:start](n)
    G = zeros(n)
    tf.gradient!(G, x)
    @test G ≈ axisparallelhyperellipsoid_gradient(x) atol=1e-6

    # Start away from min
    @test tf.f(tf.meta[:start](n)) > tf.meta[:min_value](n) + 1e-3

    # Optimization
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) < 1e-5
    @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
end