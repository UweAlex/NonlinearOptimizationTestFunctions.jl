# test/holdertable_tests.jl
# Purpose: Tests for the HolderTable test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, and optimization.
# Last modified: 16. August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: HOLDERTABLE_FUNCTION, holdertable

@testset "HolderTable Function Tests" begin
    tf = HOLDERTABLE_FUNCTION
    n = 2
    start = tf.meta[:start](n)
    min_pos = tf.meta[:min_position](n)
    min_val = tf.meta[:min_value]
    @test tf.f([0.0, 0.0]) ≈ 0.0 atol=1e-6  # Separater Test für [0,0]
    @test tf.f(min_pos) ≈ min_val atol=1e-4
    result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) < tf.f(start) + 1e-3  # Nur Verbesserung prüfen, da lokal
    small_x = fill(1e-308, n)
    @test isfinite(tf.f(small_x))
end