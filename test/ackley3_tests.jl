# test/ackley3_tests.jl
# Purpose: Tests for the Ackley3 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function value, gradient, and optimization behavior.
# Last modified: August 30, 2025

using Test, NonlinearOptimizationTestFunctions, Optim

@testset "Ackley3 Tests" begin
    tf = NonlinearOptimizationTestFunctions.ACKLEY3_FUNCTION
    
    # Verify metadata
    @test tf.meta[:name] == "ackley3"
    @test tf.meta[:properties] == Set(["unimodal", "non-separable", "differentiable", "continuous", "bounded"])
    @test tf.meta[:in_molga_smutnicki_2005] == false
    
    # Test function value at known points
    @test isapprox(tf.f([0.0, 0.0]), -200.0 + 5.0 * exp(1.0), atol=1e-6)
    @test isapprox(tf.f(tf.meta[:min_position]()), -195.629028238419, atol=1e-6)
    
    
end