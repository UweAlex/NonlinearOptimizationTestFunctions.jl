# test/matyas_tests.jl
# Purpose: Tests for the Matyas test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 27 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: MATYAS_FUNCTION, matyas

@testset "Matyas Function Tests" begin
    tf = MATYAS_FUNCTION
    # Metadata tests for non-scalable function (n=2)
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() == [0.0, 0.0]
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:lb]() == [-10.0, -10.0]
    @test tf.meta[:ub]() == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test tf.meta[:properties] == Set(["bounded", "continuous", "convex", "differentiable", "non-separable", "unimodal"])
    
    # Function value tests
    start = tf.meta[:start]()
    min_pos = tf.meta[:min_position]()
    min_val = tf.meta[:min_value]
    @test tf.f(start) ≈ 0.0 atol=1e-6  # 0.26*(0^2 + 0^2) - 0.48*0*0 = 0
    @test tf.f(min_pos) ≈ min_val atol=1e-6  # Minimum at (0, 0) is 0
    
    # Optimization test with Fminbox to respect bounds
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ min_val atol=1e-4
    @test Optim.minimizer(result) ≈ min_pos atol=0.1
    
    # Edge case tests
    @test_throws ArgumentError tf.f(Float64[])  # Empty input
    @test isnan(tf.f([NaN, NaN]))  # NaN input
    @test isfinite(tf.f([-10.0, -10.0]))  # Lower bound
    @test isfinite(tf.f([10.0, 10.0]))   # Upper bound
    @test isfinite(tf.f([1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Incorrect dimension
end