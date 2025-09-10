# test/bukin4_tests.jl
# Purpose: Tests for the Bukin 4 test function.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 10 September 2025

using Test
using NonlinearOptimizationTestFunctions
using Optim

tf = BUKIN4_FUNCTION

@testset "Bukin 4 Function and Gradient" begin
    # Funktionswerte
    @test isapprox(tf.f([-5.0, 0.0]), 0.05, atol=1e-6)  # Startpunkt
    @test isapprox(tf.f([-10.0, 0.0]), 0.0, atol=1e-6)  # Minimum
    @test isapprox(tf.f([-15.0, 3.0]), 900.05, atol=1e-6)  # Obere Schranke

    # Gradient
    @test isapprox(tf.grad([-5.0, 0.0]), [0.01, 0.0], atol=1e-6)
    @test_throws DomainError tf.grad([-10.0, 0.0])  # Teilweise differenzierbar

    # Edge Cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isfinite(tf.f([1e-308, 0.0]))
    @test_throws ArgumentError tf.f(ones(1))
    @test_throws ArgumentError tf.f(ones(3))

    # Optimierung mit NelderMead (wegen partially differentiable und bounded)
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    start = tf.meta[:start]()
    result = optimize(tf.f, lb, ub, start, Fminbox(NelderMead()), Optim.Options(f_abstol=1e-6, x_abstol=1e-3))
    @test isapprox(Optim.minimum(result), 0.0, atol=1e-6)
    @test isapprox(Optim.minimizer(result), [-10.0, 0.0], atol=1e-3)
end