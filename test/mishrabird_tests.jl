# test/mishrabird_tests.jl
# Purpose: Tests for the MishraBird function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 18 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: MISHRAbird_FUNCTION, mishrabird

@testset "MishraBird Tests" begin
    tf = MISHRAbird_FUNCTION
    n = 2 

    # Minima position
    min_pos1 = [-3.1302468, -1.5821422]

    # Edge Cases
    @test_throws ArgumentError mishrabird(Float64[])
    @test_throws ArgumentError mishrabird([1.0])
    @test isnan(mishrabird(fill(NaN, n)))
    @test isinf(mishrabird(fill(Inf, n)))
    @test isfinite(mishrabird(fill(1e-308, n)))

    # Function Values
    # The second minimum from literature [-6.7745761, -2.4183762] is incorrect for this formula.
    @test mishrabird(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test mishrabird(tf.meta[:start](n)) ≈ 15.005388 atol=1e-5 # Corrected expected value

    # Metadata
    @test tf.meta[:name] == "mishrabird"
    @test tf.meta[:start](n) == [-1.0, -1.0]
    @test tf.meta[:min_position](n) ≈ min_pos1 atol=1e-6
    @test tf.meta[:min_value] ≈ -106.764537 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -6.5]
    @test tf.meta[:ub](n) == [0.0, 0.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test Set(tf.meta[:properties]) == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"])

    # Optimization Test
    @testset "Optimization Test" begin
        start = tf.meta[:start](n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-8))
        minimizer = Optim.minimizer(result)
        
        # Check if the found minimum is close to the valid global minimum
        is_close_to_min1 = isapprox(minimizer, min_pos1, atol=1e-3)
        
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test is_close_to_min1
    end
end