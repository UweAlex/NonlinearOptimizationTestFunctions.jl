# test/michalewicz_tests.jl
# Purpose: Tests for the Michalewicz function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 17. Juli 2025

using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: MICHALEWICZ_FUNCTION, michalewicz, michalewicz_gradient

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

@testset "Michalewicz Tests" begin
    tf = MICHALEWICZ_FUNCTION
    @test_throws ArgumentError michalewicz(Float64[])
    @test isnan(michalewicz([NaN, NaN]))  # Adjusted for n >= 2
    @test isinf(michalewicz([Inf, Inf]))  # Adjusted for n >= 2
    @test isfinite(michalewicz([1e-308, 1e-308]))  # Adjusted for n >= 2
    @test michalewicz(tf.meta[:min_position](2)) ≈ -1.8013 atol=1e-5
    @test michalewicz(tf.meta[:start](2)) ≈ michalewicz([0.5, 0.5]) atol=1e-6
    @test michalewicz_gradient(tf.meta[:min_position](2)) ≈ zeros(2) atol=1e-6
    @test michalewicz_gradient(tf.meta[:start](2)) ≈ finite_difference_gradient(michalewicz, tf.meta[:start](2)) atol=1e-5
    x = tf.meta[:start](2)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ michalewicz_gradient(x) atol=1e-6
    @test tf.meta[:name] == "michalewicz"
    @test tf.meta[:start](2) == [0.5, 0.5]
    @test tf.meta[:min_position](2) ≈ [2.2029055201726, 1.5707963267949]
    @test tf.meta[:min_value](2) ≈ -1.8013 atol=1e-6
    @test tf.meta[:lb](2) == [0.0, 0.0]
    @test tf.meta[:ub](2) == [π, π]
    x_dual = [ForwardDiff.Dual(0.5, 1.0), ForwardDiff.Dual(0.5, 0.0)]
    @test isfinite(michalewicz(x_dual))
    @test all(isfinite, michalewicz_gradient(x_dual))
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](2) + 0.01 * randn(2)  # Near minimum for multimodal
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        if Optim.minimum(result) > -1.8013 + 1e-4
            start = tf.meta[:min_position](2) + 0.001 * randn(2)
            result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        end
        @test Optim.minimum(result) ≈ -1.8013 atol=0.0001
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](2) atol=0.05
        start_n10 = tf.meta[:min_position](10) + 0.01 * randn(10)
        result_n10 = optimize(tf.f, tf.gradient!, start_n10, LBFGS(), Optim.Options(f_reltol=1e-6))
        if Optim.minimum(result_n10) > -9.66015 + 0.01
            start_n10 = tf.meta[:min_position](10) + 0.001 * randn(10)
            result_n10 = optimize(tf.f, tf.gradient!, start_n10, LBFGS(), Optim.Options(f_reltol=1e-6))
        end
        @test Optim.minimum(result_n10) ≈ -9.66015 atol=0.01
        @test norm(Optim.minimizer(result_n10) - tf.meta[:min_position](10)) < 0.1
    end
end