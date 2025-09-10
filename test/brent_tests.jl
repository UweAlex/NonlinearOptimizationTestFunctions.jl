# test/brent_tests.jl
# Purpose: Tests for the Brent test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization behavior.
# Last modified: August 31, 2025

using Test
using NonlinearOptimizationTestFunctions: BRENT_FUNCTION, brent
using Optim
using ForwardDiff

@testset "Brent Tests" begin
    # Reference to the Brent TestFunction instance
    tf = BRENT_FUNCTION

    # Test metadata
    @test tf.meta[:name] == "brent"  # Verify function name
    @test tf.meta[:properties] == Set(["continuous", "differentiable", "non-separable", "unimodal", "bounded"])  # Verify properties
    @test tf.meta[:in_molga_smutnicki_2005] == false  # Verify source information

    # Test function values at key points
    x_start = tf.meta[:start]()  # [0.0, 0.0]
    x_min = tf.meta[:min_position]()  # [-10.0, -10.0]
    @test tf.f(x_start) ≈ 201.0 atol=1e-6  # f(0,0) = (10)^2 + (10)^2 + exp(0) = 100 + 100 + 1
    @test tf.f(x_min) ≈ 0.0 atol=1e-6  # f(-10,-10) = (0)^2 + (0)^2 + exp(-200) ≈ 0
    @test tf.f([1.0, 1.0]) ≈ 242.1353352832366 atol=1e-6  # Manual calculation: (1+10)^2 + (1+10)^2 + exp(-2)

    # Test gradient at minimum (numerical comparison in runtests.jl, only basic check here)
    grad_fd = ForwardDiff.gradient(tf.f, x_min)  # Numerical gradient via ForwardDiff
    @test isapprox(tf.grad(x_min), grad_fd, atol=1e-6)  # Analytical vs numerical gradient
    @test isapprox(tf.grad(x_min), [0.0, 0.0], atol=1e-3)  # Gradient at minimum nearly zero

    # Test edge cases as required by runtests.jl
    @test_throws ArgumentError tf.f(Float64[])  # Empty input
    @test isnan(tf.f([NaN, 0.0]))  # NaN input
    @test isnan(tf.f([0.0, NaN]))  # NaN input
    @test isfinite(tf.f(tf.meta[:lb]()))  # Lower bound [-10, -10]
    @test isfinite(tf.f(tf.meta[:ub]()))  # Upper bound [10, 10]
    @test isfinite(tf.f([1e-308, 1e-308]))  # Small input
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Wrong dimension

    # Optimization test using Fminbox to respect bounds
    # Use LBFGS with loose tolerances for unimodal function
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), x_start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimizer(result), x_min, atol=1e-2)  # Minimizer close to [-10, -10]
    @test isapprox(Optim.minimum(result), 0.0, atol=1e-4)  # Minimum value close to 0
end