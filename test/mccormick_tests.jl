# test/mccormick_tests.jl
# Purpose: Tests for the McCormick test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 27 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: MCCORMICK_FUNCTION, mccormick

@testset "McCormick Tests" begin
    tf = MCCORMICK_FUNCTION
    # Metadata tests for non-scalable function (n=2)
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [-0.54719755, -1.54719755] atol=1e-6
    @test tf.meta[:min_value] == -1.91322295
    @test tf.meta[:lb]() == [-1.5, -3.0]
    @test tf.meta[:ub]() == [4.0, 4.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test tf.meta[:properties] == Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex"])
    
    # Function value tests
    start = tf.meta[:start]()
    min_pos = tf.meta[:min_position]()
    min_val = tf.meta[:min_value]
    @test tf.f(start) ≈ 1.0 atol=1e-6  # sin(0 + 0) + (0 - 0)^2 - 1.5*0 + 2.5*0 + 1 = 1.0
    @test tf.f(min_pos) ≈ min_val atol=1e-6  # Minimum at (-0.54719755, -1.54719755) is -1.91322295
    
    # Optimization test with Fminbox to respect bounds
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ min_val atol=1e-4
    @test Optim.minimizer(result) ≈ min_pos atol=0.1
    
    # Edge case tests
    @test_throws ArgumentError tf.f(Float64[])  # Empty input
    @test isnan(tf.f([NaN, NaN]))  # NaN input
    @test isfinite(tf.f([-1.5, -3.0]))  # Lower bound
    @test isfinite(tf.f([4.0, 4.0]))   # Upper bound
    @test isfinite(tf.f([1e-308, 1e-308]))  # Small values
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Incorrect dimension
end