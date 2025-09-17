# test/ackley2_tests.jl
# Purpose: Tests for the Ackley2 function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, gradient, and optimization with Optim.jl.
# Note: The :min_value definition in src/functions/ackley2.jl is () -> -200.0, which does not conform to the expected (n::Int) -> Real signature. Tests are adapted to handle this.
# Last modified: September 13, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: ACKLEY2_FUNCTION, ackley2, ackley2_gradient

@testset "Ackley2 Tests" begin
    tf = ACKLEY2_FUNCTION
    n = 2  # Ackley2 is fixed to n=2

    # Test metadata
    @testset "Metadata Tests" begin
        @test tf.meta[:name] == "ackley2"
        @test tf.meta[:start]() ≈ [0.0, 0.0] atol=1e-6
        @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
        @test tf.meta[:min_value]() ≈ -200.0 atol=1e-6  # Adapted to non-standard :min_value definition
        @test tf.meta[:lb]() ≈ [-32.0, -32.0] atol=1e-6
        @test tf.meta[:ub]() ≈ [32.0, 32.0] atol=1e-6
        @test Set(tf.meta[:properties]) == Set(["unimodal", "non-convex", "non-separable", "partially differentiable", "continuous", "bounded"])
    end

    # Test edge cases
    @testset "Edge Cases" begin
        @test_throws ArgumentError ackley2(Float64[])  # Empty input
        @test_throws ArgumentError ackley2([1.0, 2.0, 3.0])  # Wrong dimension
        @test isnan(ackley2([NaN, 0.0]))  # NaN input
        @test isinf(ackley2([Inf, 0.0]))  # Inf input
        @test isfinite(ackley2([1e-308, 1e-308]))  # Small input
    end

    # Test function values
    @testset "Function Values" begin
        min_pos = tf.meta[:min_position]()
        min_val = tf.meta[:min_value]()
        @test ackley2(min_pos) ≈ min_val atol=1e-6  # Value at global minimum
        @test ackley2([1.0, 1.0]) ≈ -194.42239680657946 atol=1e-6  # Value at [1.0, 1.0]
        @test ackley2([0.1, 0.1]) ≈ -199.43511382133656 atol=1e-6  # Corrected value at [0.1, 0.1]
    end

    # Test gradient
    @testset "Gradient Tests" begin
        grad = zeros(n)
        tf.gradient!(grad, tf.meta[:min_position]())
        @test grad ≈ zeros(n) atol=1e-3  # Gradient at minimum (handled as [0, 0])
        @test ackley2_gradient([0.1, 0.1]) ≈ [2.82043842779556, 2.82043842779556] atol=1e-6  # Gradient at [0.1, 0.1]
    end

    # Test optimization
    @testset "Optimization Tests" begin
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        start = [0.1, 0.1]  # Deterministic start point near minimum
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
        @test Optim.converged(result)
        @test Optim.minimum(result) ≈ tf.meta[:min_value]() atol=1e-4
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end

    # Test start point within bounds
    @testset "Start Point Bounds" begin
        start = tf.meta[:start]()
        lb = tf.meta[:lb]()
        ub = tf.meta[:ub]()
        @test all(lb .<= start .<= ub)  # Ensure start point is within bounds
    end
end