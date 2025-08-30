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
    
    # Test optimization with Optim.jl
    result = optimize(tf.f, tf.gradient!, [0.7, -0.4], LBFGS(), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimum(result), -195.629028238419, atol=1e-4)
    @test isapprox(Optim.minimizer(result), [0.682584587365898, -0.36075325513719], atol=1e-2)
end