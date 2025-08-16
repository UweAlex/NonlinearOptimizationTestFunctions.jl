# test/matyas_tests.jl
# Purpose: Tests for the Matyas test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, and optimization.
# Last modified: 16. August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: MATYAS_FUNCTION, matyas

@testset "Matyas Function Tests" begin
    tf = MATYAS_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    min_val = tf.meta[:min_value]
    @test tf.f(start) ≈ 0.0 atol=1e-6  # Berechnet: 0.26*(0+0) - 0.48*0*0 = 0
    @test tf.f(min_pos) ≈ min_val atol=1e-6
    result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ min_val atol=1e-4
    @test Optim.minimizer(result) ≈ min_pos atol=0.1
    # Edge cases
    small_x = fill(1e-308, n)
    @test isfinite(tf.f(small_x))
end