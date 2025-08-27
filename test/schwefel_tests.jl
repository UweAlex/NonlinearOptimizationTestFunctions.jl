# test/schwefel_tests.jl
# Purpose: Tests for the Schwefel function in NonlinearOptimizationTestFunctions.
# Context: Part of the test suite to verify the correctness of the Schwefel function, its gradient, metadata, and optimization behavior. Ensures compatibility with ForwardDiff and Optim.jl, and tests edge cases and scalability as per the requirements in the project documentation.
# Last modified: August 22, 2025

using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: SCHWEFEL_FUNCTION, schwefel, schwefel_gradient

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

@testset "schwefel tests" begin
    tf = SCHWEFEL_FUNCTION
    # Metadatentests
    @test tf.meta[:name] == "schwefel"
    @test tf.meta[:lb](2) == fill(-500.0, 2)
    @test tf.meta[:ub](2) == fill(500.0, 2)
    @test tf.meta[:lb](3) == fill(-500.0, 3)
    @test tf.meta[:ub](3) == fill(500.0, 3)
    @test tf.meta[:start](3) == fill(1.0, 3)
    @test tf.meta[:min_position](3) ≈ fill(420.9687463209481, 3) atol=1e-6
    @test tf.meta[:min_value] ≈ 0.0 atol=1e-6
    @test tf.meta[:properties] == Set(["multimodal", "separable", "bounded", "differentiable", "scalable", "non-convex", "continuous"])
    # Funktionstests
    @test_throws ArgumentError schwefel(Float64[])
    @test isnan(schwefel([NaN, NaN]))
    @test isinf(schwefel([Inf, Inf]))
    @test isfinite(schwefel([1e-308, 1e-308]))
    @test schwefel([420.9687, 420.9687]) ≈ 0.0 atol=3e-5
    @test schwefel([1.0, 1.0]) ≈ 836.282858 atol=1e-6
    # Gradiententests
    @test schwefel_gradient([420.9687, 420.9687]) ≈ [0.0, 0.0] atol=2e-5
    @test schwefel_gradient([1.0, 1.0]) ≈ [-1.1116221377, -1.1116221377] atol=1e-6
    @test schwefel_gradient([1.0, 1.0]) ≈ finite_difference_gradient(schwefel, [1.0, 1.0]) atol=1e-6
    x = tf.meta[:start](2)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test G ≈ schwefel_gradient(x) atol=1e-6
    # ForwardDiff-Kompatibilität
  x_dual = [ForwardDiff.Dual(0.5, 1.0), ForwardDiff.Dual(0.5, 0.0)]
    @test isfinite(schwefel(x_dual))
    @test all(isfinite, schwefel_gradient(x_dual))
    # Optimierungstests
    @testset "optimization tests" begin
        start = tf.meta[:min_position](2) + 0.01 * randn(2) # Nahe Minimum für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6, iterations=10000))
        @test Optim.minimum(result) < 3e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](2) atol=1e-3
        start_n10 = tf.meta[:min_position](10) + 0.01 * randn(10)
        result_n10 = optimize(tf.f, tf.gradient!, start_n10, LBFGS(), Optim.Options(f_reltol=1e-6, iterations=10000))
        @test Optim.minimum(result_n10) < 0.0002
        @test Optim.minimizer(result_n10) ≈ tf.meta[:min_position](10) atol=1e-3
        start_n100 = tf.meta[:min_position](100) + 0.01 * randn(100)
        result_n100 = optimize(tf.f, tf.gradient!, start_n100, LBFGS(), Optim.Options(f_reltol=1e-6, iterations=10000))
        @test Optim.minimum(result_n100) < 0.002
        @test Optim.minimizer(result_n100) ≈ tf.meta[:min_position](100) atol=1e-3
    end
end