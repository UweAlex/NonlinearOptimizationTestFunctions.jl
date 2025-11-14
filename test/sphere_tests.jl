# test/sphere_tests.jl
# Purpose: Tests for the Sphere function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, gradients, and metadata.
# Last modified: 23. Oktober 2025, 15:00 PM CEST

using Test, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: SPHERE_FUNCTION, sphere, sphere_gradient

@testset "Sphere Tests" begin
    tf = SPHERE_FUNCTION
    n = tf.meta[:default_n]
    @test n >= 2

    # Edge Cases
    @test_throws ArgumentError sphere(Float64[])  # n==0
    @test_throws ArgumentError sphere([1.0])  # n<2 → "sphere requires..."
    @test isnan(sphere([NaN, 1.0]))
    @test isinf(sphere([Inf, 1.0]))
    @test isfinite(sphere([1e-308, 1e-308]))

    # Function Values
    @test sphere(fill(0.0, n)) ≈ 0.0 atol=1e-8
    @test sphere(fill(1.0, n)) ≈ n atol=1e-8

    # Gradients
    @test all(isapprox.(sphere_gradient(fill(0.0, n)), fill(0.0, n), atol=1e-8))
    @test all(isapprox.(sphere_gradient(fill(1.0, n)), fill(2.0, n), atol=1e-8))

    # In-Place Gradient
    x = tf.meta[:start](n)
    G = zeros(length(x))
    tf.gradient!(G, x)
    @test all(isapprox.(G, sphere_gradient(x), atol=1e-6))

    # ForwardDiff Compatibility
    @test all(isapprox.(ForwardDiff.gradient(sphere, [1.0, 1.0]), sphere_gradient([1.0, 1.0]), atol=1e-8))

    # Meta Validation
    @test tf.meta[:name] == "sphere"  # Hart-Check
    @test length(tf.meta[:start](n)) == n
    @test all(isapprox.(tf.meta[:min_position](n), fill(0.0, n), atol=1e-8))
    @test tf.f(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol=1e-8
    @test all(isapprox.(tf.meta[:lb](n), fill(-5.12, n), atol=1e-8))
    @test all(isapprox.(tf.meta[:ub](n), fill(5.12, n), atol=1e-8))

    # Properties
    @test has_property(tf, "unimodal")
    @test has_property(tf, "scalable")
    @test has_property(tf, "convex")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "bounded")

    # Additional Scalability Test (e.g., for n=3)
    n_alt = 3
    @test sphere(fill(1.0, n_alt)) ≈ n_alt atol=1e-8
    @test all(isapprox.(sphere_gradient(fill(1.0, n_alt)), fill(2.0, n_alt), atol=1e-8))
    @test tf.f(tf.meta[:min_position](n_alt)) ≈ tf.meta[:min_value](n_alt) atol=1e-8

    # Type Stability Check (SHOULD per RULE_DEFAULT_N)
    @code_warntype sphere(rand(n))
    @code_warntype sphere_gradient(rand(n))
end