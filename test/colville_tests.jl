# test/colville_tests.jl
# Purpose: Tests for the Colville test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function evaluation, metadata, edge cases, and optimization.
# Last modified: 30 August 2025

using Test
using NonlinearOptimizationTestFunctions
using ForwardDiff
using Optim
using LinearAlgebra

@testset "Colville Tests" begin
    tf = NonlinearOptimizationTestFunctions.COLVILLE_FUNCTION
    
    # Metadaten-Tests
    @test tf.meta[:name] == "colville"
    @test tf.meta[:properties] == Set(["unimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    @test tf.meta[:min_value]() == 0.0
    @test tf.meta[:start]() == [0.0, 0.0, 0.0, 0.0]
    @test tf.meta[:min_position]() == [1.0, 1.0, 1.0, 1.0]
    @test tf.meta[:lb]() == fill(-10.0, 4)
    @test tf.meta[:ub]() == fill(10.0, 4)
    
    # Funktionswert-Tests
    @test isapprox(tf.f([1.0, 1.0, 1.0, 1.0]), 0.0, atol=1e-6)
    @test isapprox(tf.f([0.0, 0.0, 0.0, 0.0]), 42.0, atol=1e-6)
    
    # Gradienten-Tests
    grad = tf.grad([0.5, 0.5, 0.5, 0.5])
    grad_fd = ForwardDiff.gradient(tf.f, [0.5, 0.5, 0.5, 0.5])
    @test isapprox(grad, grad_fd, atol=1e-6)
    @test isapprox(tf.grad([1.0, 1.0, 1.0, 1.0]), zeros(4), atol=1e-3)
    
    # Edge Cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0, 0.0, 0.0]))
    @test isinf(tf.f([Inf, 0.0, 0.0, 0.0]))
    @test_throws ArgumentError tf.f([0.0, 0.0, 0.0])  # Falsche Dimension (n=3)
    @test_throws ArgumentError tf.f([0.0, 0.0, 0.0, 0.0, 0.0])  # Falsche Dimension (n=5)
    @test isfinite(tf.f(fill(1e-308, 4)))
    @test isfinite(tf.f(tf.meta[:lb]()))
    @test isfinite(tf.f(tf.meta[:ub]()))
    
    # Optimierungstests
    result_nm = optimize(tf.f, tf.meta[:start](), NelderMead(), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimizer(result_nm), [1.0, 1.0, 1.0, 1.0], atol=1e-2)
    @test isapprox(Optim.minimum(result_nm), 0.0, atol=1e-4)
    
    result_lbfgs = optimize(tf.f, tf.gradient!, tf.meta[:start](), LBFGS(), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimizer(result_lbfgs), [1.0, 1.0, 1.0, 1.0], atol=1e-2)
    @test isapprox(Optim.minimum(result_lbfgs), 0.0, atol=1e-4)
    
    # Bounded Optimierung
    initial_x = tf.meta[:start]()
    od = OnceDifferentiable(tf.f, tf.gradient!, initial_x)
    result_fminbox = optimize(od, tf.meta[:lb](), tf.meta[:ub](), initial_x, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimizer(result_fminbox), [1.0, 1.0, 1.0, 1.0], atol=1e-2)
    @test isapprox(Optim.minimum(result_fminbox), 0.0, atol=1e-4)
end