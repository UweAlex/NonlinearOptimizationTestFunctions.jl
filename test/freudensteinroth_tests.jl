# test/freudensteinroth_tests.jl
# Purpose: Tests for the Freudenstein-Roth test function in NonlinearOptimizationTestFunctions.
# Context: Validates function evaluation, metadata, edge cases, and compatibility with Optim.jl.
# Last modified: 31 August 2025

using Test
using NonlinearOptimizationTestFunctions: FREUDENSTEINROTH_FUNCTION, freudensteinroth
using Optim
using LinearAlgebra

@testset "Freudenstein-Roth Tests" begin
    tf = FREUDENSTEINROTH_FUNCTION
    n = 2  # Fixed dimension for Freudenstein-Roth

    # Test metadata
    @test tf.meta[:name] == "freudensteinroth"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test tf.meta[:start]() == [4.99, 3.99]
    @test tf.meta[:min_position]() == [5.0, 4.0]
    @test tf.meta[:min_value]() == 0.0
    @test tf.meta[:lb]() == [-10.0, -10.0]
    @test tf.meta[:ub]() == [10.0, 10.0]

    # Test function evaluation at start point
    start = tf.meta[:start]()
    @test isapprox(freudensteinroth(start), 0.191759209, atol=1e-4)  # Corrected value: f([4.99, 3.99]) ≈ 0.191759209

    # Test function evaluation at minimum
    min_pos = tf.meta[:min_position]()
    @test isapprox(freudensteinroth(min_pos), tf.meta[:min_value](), atol=1e-6)

    # Test edge cases
    @test_throws ArgumentError freudensteinroth(Float64[])  # Empty input
    @test_throws ArgumentError freudensteinroth([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(freudensteinroth([NaN, 1.0]))
    @test isinf(freudensteinroth([Inf, 1.0]))
    @test isfinite(freudensteinroth([1e-308, 1e-308]))
    @test isfinite(freudensteinroth(tf.meta[:lb]()))  # Lower bound
    @test isfinite(freudensteinroth(tf.meta[:ub]()))  # Upper bound

    # Test compatibility with Optim.jl (NelderMead, derivative-free)
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    start = tf.meta[:start]()
    result_nm = optimize(
        tf.f, lb, ub, start, Fminbox(NelderMead()),
        Optim.Options(f_reltol=1e-4, iterations=10000)
    )
    @test isfinite(Optim.minimum(result_nm))  # Ensure finite result
    @test all(lb .<= Optim.minimizer(result_nm) .<= ub)  # Ensure bounds are respected

    # Verify that gradient tests are not included here (handled in runtests.jl)
end