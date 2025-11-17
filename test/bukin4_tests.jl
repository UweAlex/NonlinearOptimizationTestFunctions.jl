# test/bukin4_tests.jl
# Purpose: Tests for the Bukin 4 test function.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: November 17, 2025

using Test
using NonlinearOptimizationTestFunctions
using Optim

@testset "Bukin 4 Function and Gradient" begin
    tf = BUKIN4_FUNCTION

    # Metadata
    @test tf.meta[:name] == "bukin4"
    @test Set(tf.meta[:properties]) == Set(["bounded", "continuous", "multimodal", "non-convex", "partially differentiable", "separable"])

    # Funktionswerte
    @test isapprox(tf.f(tf.meta[:start]()), 0.049, atol=1e-6)  # Startpunkt
    @test isapprox(tf.f(tf.meta[:min_position]()), 0.0, atol=1e-6)  # Minimum
    @test isapprox(tf.f(tf.meta[:ub]()), 900.05, atol=1e-6)  # Obere Schranke

    # Gradient
    @test isapprox(tf.grad(tf.meta[:start]()), [0.01, 0.0], atol=1e-6)
    @test all(isnan.(tf.grad(tf.meta[:min_position]())))  # NaN at non-diff point

    # Edge Cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isfinite(tf.f([1e-308, 0.0]))
    @test_throws ArgumentError tf.f(ones(1))
    @test_throws ArgumentError tf.f(ones(3))

    # Optimierung mit Fminbox(NelderMead()) due to bounded and partially differentiable
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    start = tf.meta[:start]()
    result = optimize(tf.f, lb, ub, start, Fminbox(NelderMead()), Optim.Options(f_abstol=1e-6, x_abstol=1e-3))
    @test Optim.converged(result)
    @test isapprox(Optim.minimum(result), 0.0, atol=1e-6)
    @test isapprox(Optim.minimizer(result), tf.meta[:min_position](), atol=1e-3)
end