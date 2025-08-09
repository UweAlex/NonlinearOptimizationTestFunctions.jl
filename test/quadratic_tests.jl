# test/quadratic_tests.jl
# Purpose: Tests for the generic quadratic function with encapsulated parameters set on first call.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 09 August 2025

using Test, Optim, LinearAlgebra
using NonlinearOptimizationTestFunctions: QUADRATIC_FUNCTION, quadratic, quadratic_gradient

# Reset encapsulated parameters
function reset_quadratic()
    NonlinearOptimizationTestFunctions.A_fixed[] = nothing
    NonlinearOptimizationTestFunctions.b_fixed[] = nothing
    NonlinearOptimizationTestFunctions.c_fixed[] = nothing
    NonlinearOptimizationTestFunctions.is_initialized[] = false
end

# Diagnosetests für Importe
@testset "Import Tests" begin
    @test isdefined(NonlinearOptimizationTestFunctions, :QUADRATIC_FUNCTION)
    @test isdefined(NonlinearOptimizationTestFunctions, :quadratic)
    @test isdefined(NonlinearOptimizationTestFunctions, :quadratic_gradient)
end

@testset "Quadratic Tests" begin
    tf = NonlinearOptimizationTestFunctions.QUADRATIC_FUNCTION
    n = 2  # Standard dimension
    n_high = 10  # Higher dimension for scalability

    # Edge Cases
    reset_quadratic()
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f(fill(NaN, n)))
    @test isinf(tf.f(fill(Inf, n)))
    @test isfinite(tf.f(fill(1e-308, n)))

    # Test with default parameters (b=0, c=0)
    reset_quadratic()
    tf.f(zeros(n))  # Initialize default parameters
    @test tf.f(tf.meta[:min_position](n)) ≈ tf.meta[:min_value](n) atol=1e-6
    @test tf.meta[:min_position](n) ≈ zeros(n) atol=1e-6
    @test tf.meta[:min_value](n) ≈ 0.0 atol=1e-6

    # Test with custom parameters
    reset_quadratic()
    A = Symmetric(Matrix(Diagonal([2.0, 2.0])))  # Deterministic positive definite matrix
    b = ones(n)
    c = 0.5
    val1 = NonlinearOptimizationTestFunctions.quadratic(ones(n), A, b, c)  # Set parameters
    val2 = tf.f(ones(n))  # Use stored parameters
    @test val1 ≈ val2 atol=1e-6
    @test tf.f(ones(n)) ≈ dot(ones(n), A*ones(n)) + dot(b, ones(n)) + c atol=1e-6

    # Test minimum
    x_min = tf.meta[:min_position](n)
    min_value = tf.meta[:min_value](n)
    @test tf.f(x_min) ≈ min_value atol=1e-6
    @test x_min ≈ -0.5 * (A\b) atol=1e-6
    @test min_value ≈ c - 0.25 * dot(b, A\b) atol=1e-6

    # Test with different parameters
    reset_quadratic()
    A_new = Symmetric(Matrix(Diagonal([3.0, 3.0])))  # Another deterministic positive definite matrix
    b_new = zeros(n)
    c_new = 0.0
    val3 = NonlinearOptimizationTestFunctions.quadratic(ones(n), A_new, b_new, c_new)  # Set new parameters
    val4 = tf.f(ones(n))  # Use new parameters
    @test val3 ≈ val4 atol=1e-6
    @test tf.f(ones(n)) ≈ dot(ones(n), A_new*ones(n)) + dot(b_new, ones(n)) + c_new atol=1e-6

    # Test gradient
    @test NonlinearOptimizationTestFunctions.quadratic_gradient(ones(n)) ≈ 2 * A_new * ones(n) + b_new atol=1e-6

    # Metadata
    @test tf.meta[:name] == "quadratic"
    @test tf.meta[:start](n) == fill(0.0, n)
    @test tf.meta[:lb](n) == fill(-Inf, n)
    @test tf.meta[:ub](n) == fill(Inf, n)
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["unimodal", "convex", "non-separable", "differentiable", "scalable"])

    # Optimization tests
    @testset "Optimization Tests" begin
        reset_quadratic()
        NonlinearOptimizationTestFunctions.quadratic(zeros(n), A, b, c)  # Set parameters
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value](n) atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3

        result_cg = optimize(tf.f, tf.gradient!, start, ConjugateGradient(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result_cg) ≈ tf.meta[:min_value](n) atol=1e-5
        @test Optim.minimizer(result_cg) ≈ tf.meta[:min_position](n) atol=1e-3
    end

    # Scalability: Test for n=10
    reset_quadratic()
    A_high = Symmetric(Matrix(Diagonal(fill(2.0, n_high))))  # Deterministic positive definite matrix
    b_high = ones(n_high)
    c_high = 0.5
    NonlinearOptimizationTestFunctions.quadratic(ones(n_high), A_high, b_high, c_high)  # Set parameters
    @test tf.f(tf.meta[:min_position](n_high)) ≈ tf.meta[:min_value](n_high) atol=1e-6
    @test tf.meta[:min_position](n_high) ≈ -0.5 * (A_high\b_high) atol=1e-6
    @test tf.meta[:min_value](n_high) ≈ c_high - 0.25 * dot(b_high, A_high\b_high) atol=1e-6

    # Optimization for n=10
    start_high = tf.meta[:start](n_high)
    result_high = optimize(tf.f, tf.gradient!, start_high, LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.minimum(result_high) ≈ tf.meta[:min_value](n_high) atol=1e-5
    @test Optim.minimizer(result_high) ≈ tf.meta[:min_position](n_high) atol=1e-3

    # Edge Case: Invalid dimension
    reset_quadratic()
    @test_throws ArgumentError tf.meta[:start](0)
    @test_throws ArgumentError tf.meta[:lb](0)
    @test_throws ArgumentError tf.meta[:ub](0)

    # Test for non-positive definite matrix
    reset_quadratic()
    A_invalid = zeros(n, n)  # Non-positive definite
    @test_throws ArgumentError NonlinearOptimizationTestFunctions.quadratic(ones(n), A_invalid, b, c)
end