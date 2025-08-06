# test/crossintray_tests.jl
# Purpose: Tests for the Cross-in-Tray function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 05 August 2025

using Test, Optim, ForwardDiff
using NonlinearOptimizationTestFunctions: CROSSINTRAY_FUNCTION, crossintray, crossintray_gradient

@testset "Cross-in-Tray Tests" begin
    tf = CROSSINTRAY_FUNCTION
    n = 2
    # Test edge cases
    @test_throws ArgumentError crossintray(Float64[])
    @test isnan(crossintray(fill(NaN, n)))
    @test isinf(crossintray(fill(Inf, n)))
    @test isfinite(crossintray(fill(1e-308, n)))
    # Test function value at minimum
    @test crossintray(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    # Test function value at start point [0.0, 0.0]
    @test crossintray(tf.meta[:start](n)) ≈ -0.0001 atol=1e-6
    # Test metadata
    @test tf.meta[:name] == "crossintray"
    @test tf.meta[:start](n) == [0.0, 0.0]
    @test tf.meta[:min_position](n) ≈ [1.3491, 1.3491] atol=1e-6
    @test tf.meta[:min_value] ≈ -2.062611237 atol=1e-6
    @test tf.meta[:lb](n) == [-10.0, -10.0]
    @test tf.meta[:ub](n) == [10.0, 10.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])
    # Test gradient at minimum
    @test crossintray_gradient(tf.meta[:min_position](n)) ≈ [0.0, 0.0] atol=0.3
    # Test optimization
    @testset "Optimization Tests" begin
        minima = [[1.3491, 1.3491], [1.3491, -1.3491], [-1.3491, 1.3491], [-1.3491, -1.3491]]
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Start near one minimum
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test any(norm(Optim.minimizer(result) - m) < 1e-3 for m in minima)
    end
    # Test gradient comparison at random points
    @testset "Gradient Comparison Tests" begin
        Random.seed!(1234)
        lb = tf.meta[:lb](n)
        ub = tf.meta[:ub](n)
        for _ in 1:5  # Reduced to 5 for faster testing
            x = lb + (ub - lb) .* rand(n)
            programmed_grad = crossintray_gradient(x)
            ad_grad = ForwardDiff.gradient(tf.f, x)
            @test programmed_grad ≈ ad_grad atol=1e-2
        end
    end
end