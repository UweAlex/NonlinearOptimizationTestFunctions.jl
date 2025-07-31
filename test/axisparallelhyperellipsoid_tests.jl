# test/axis_parallel_hyper_ellipsoid_tests.jl
# Purpose: Tests for the axis-parallel hyper-ellipsoid function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 16. Juli 2025, 08:20 AM CEST

using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctionsInJulia: AXISPARALLELHYPERELLIPSOID_FUNCTION, axisparallelhyperellipsoid, axisparallelhyperellipsoid_gradient

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
    @test_throws ArgumentError axisparallelhyperellipsoid(Float64[])
    @test isnan(axisparallelhyperellipsoid([NaN]))
    @test isinf(axisparallelhyperellipsoid([Inf]))
    @test isfinite(axisparallelhyperellipsoid([1e-308]))
    @test axisparallelhyperellipsoid([0.0]) ≈ 0.0 atol=1e-6
    @test axisparallelhyperellipsoid([1.0, 1.0]) ≈ 3.0 atol=1e-6  # 1*1^2 + 2*1^2 = 3
    @test axisparallelhyperellipsoid_gradient([0.0]) ≈ [0.0] atol=1e-6
    @test axisparallelhyperellipsoid_gradient([1.0, 1.0]) ≈ [2.0, 4.0] atol=1e-6  # [2*1*1, 2*2*1] = [2, 4]
    @test axisparallelhyperellipsoid_gradient([1.0, 1.0]) ≈ finite_difference_gradient(axisparallelhyperellipsoid, [1.0, 1.0]) atol=1e-6
    x = [1.0, 1.0]
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ axisparallelhyperellipsoid_gradient(x) atol=1e-6
    @test tf.meta[:name] == "axisparallelhyperellipsoid"
    @test tf.meta[:start](1) == [1.0]
    @test tf.meta[:min_position](1) == [0.0]
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](2), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.minimum(result) < 1e-5
    @test Optim.minimizer(result) ≈ tf.meta[:min_position](2) atol=1e-3
end