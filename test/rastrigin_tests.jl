# test/rastrigin_tests.jl
# Purpose: Tests for the Rastrigin function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, gradients, and optimization.
# Last modified: 16. Juli 2025, 14:00 PM CEST

using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: RASTRIGIN_FUNCTION, rastrigin, rastrigin_gradient

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

@testset "Rastrigin Tests" begin
    tf = RASTRIGIN_FUNCTION
    @test_throws ArgumentError rastrigin(Float64[])
    @test isnan(rastrigin([NaN]))
    @test isinf(rastrigin([Inf]))
    @test isfinite(rastrigin([1e-308]))
    @test rastrigin([0.0]) ≈ 0.0 atol=1e-6
    @test rastrigin([0.0, 0.0]) ≈ 0.0 atol=1e-6
    @test rastrigin([1.0, 1.0]) ≈ 2.0 atol=1e-6  # 10*2 + (1^2 - 10*cos(2π*1)) + (1^2 - 10*cos(2π*1)) = 20 - 18 = 2
    @test rastrigin_gradient([0.0]) ≈ [0.0] atol=1e-6
    @test rastrigin_gradient([1.0, 1.0]) ≈ [2.0, 2.0] atol=1e-6  # 2*1 + 20π*sin(2π*1) = 2
    @test rastrigin_gradient([1.0, 1.0]) ≈ finite_difference_gradient(rastrigin, [1.0, 1.0]) atol=1e-6
    x = tf.meta[:start](2)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ rastrigin_gradient(x) atol=1e-6
    @test tf.meta[:name] == "rastrigin"
    @test tf.meta[:start](1) == [1.0]
    @test tf.meta[:min_position](1) == [0.0]
    @test tf.meta[:min_value](1) ≈ 0.0 atol=1e-6
    @test tf.meta[:lb](1) == [-5.12]
    @test tf.meta[:ub](1) == [5.12]
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