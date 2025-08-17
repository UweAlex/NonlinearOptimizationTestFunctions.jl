# test/bird_tests.jl
# Purpose: Tests for the Bird test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, and optimization.
# Last modified: 16. August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: BIRD_FUNCTION, bird

@testset "Bird Function Tests" begin
    tf = BIRD_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    min_val = tf.meta[:min_value]
    @test tf.f(start) ≈ Base.MathConstants.e atol=1e-6  # Korrigierter Wert bei [0,0]
    @test tf.f(min_pos) ≈ min_val atol=1e-4  # Wert am globalen Minimum
    result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)  # Prüfe Konvergenz
    @test Optim.minimum(result) < tf.f(start) + 1e-3  # Verbesserung gegenüber Start
    small_x = fill(1e-308, n)
    @test isfinite(tf.f(small_x))  # Prüfe Stabilität bei kleinen Werten
    @test tf.grad(min_pos) ≈ zeros(n) atol=0.01  # Gradient am Minimum
end