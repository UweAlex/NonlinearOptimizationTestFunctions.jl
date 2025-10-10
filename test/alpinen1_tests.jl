# test/alpinen1_tests.jl
# Purpose: Tests for the AlpineN1 function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 28 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim
using NonlinearOptimizationTestFunctions: ALPINEN1_FUNCTION, alpinen1, alpinen1_gradient

@testset "AlpineN1 Tests" begin
    tf = ALPINEN1_FUNCTION
    n = 2

    # Test metadata
    @test tf.meta[:name] == "alpinen1"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"])

    # Test function values
    @test alpinen1(tf.meta[:min_position](n)) ≈ 0.0 atol=1e-6
    @test alpinen1(tf.meta[:start](n)) ≈ sum(abs(1.0 * sin(1.0) + 0.1 * 1.0) for _ in 1:n) atol=1e-6

    # Test edge cases
    @test_throws ArgumentError alpinen1(Float64[])
    @test isnan(alpinen1([NaN, 1.0]))
    @test isfinite(alpinen1(tf.meta[:lb](n)))
    @test isfinite(alpinen1(tf.meta[:ub](n)))
    @test isfinite(alpinen1(fill(1e-308, n)))

    # Test non-differentiability
    x_non_diff = [0.0, 0.0]
    @test_throws DomainError alpinen1_gradient(x_non_diff)

    # Compute roots for global minima positions
    using Base.MathConstants: π
    alpha = asin(-0.1)
    roots = Float64[0.0]
    for k in -2:2
        push!(roots, alpha + 2*π*k)
        push!(roots, π - alpha + 2*π*k)
    end
    filter!(x -> -10 <= x <= 10, roots)
    sort!(roots)

    # Test optimization with Fminbox(NelderMead()) due to bounds and non-differentiability
    lb = tf.meta[:lb](n)  # [-10.0, -10.0]
    ub = tf.meta[:ub](n)  # [10.0, 10.0]
    start = tf.meta[:start](n)  # [1.0, 1.0]
    result = optimize(tf.f, lb, ub, start, Fminbox(NelderMead()), Optim.Options(f_reltol=1e-6, iterations=1000))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ 0.0 atol=1e-3

    # Check each coordinate of the minimizer is close to one of the roots
    found_pos = Optim.minimizer(result)
    for pos in found_pos
        min_dist = minimum(abs(pos - r) for r in roots)
        @test min_dist < 1e-3
    end
end