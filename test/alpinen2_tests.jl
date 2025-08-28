# test/alpinen2_tests.jl
# Purpose: Tests for the AlpineN2 function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization.
# Last modified: 28 August 2025

using Test, NonlinearOptimizationTestFunctions, Optim

using NonlinearOptimizationTestFunctions: ALPINEN2_FUNCTION, alpinen2, alpinen2_gradient

@testset "AlpineN2 Tests" begin
    tf = ALPINEN2_FUNCTION
    n = 2

    # Test metadata
    @test tf.meta[:name] == "alpinen2"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "separable", "differentiable", "scalable", "bounded"])
    @test tf.meta[:in_molga_smutnicki_2005] == false

    # Test function values
    @test alpinen2(tf.meta[:min_position](n)) ≈ -2.8081311800070053^n atol=1e-6
    @test alpinen2([1.0, 1.0]) ≈ -prod(sqrt(1.0) * sin(1.0) for _ in 1:n) atol=1e-6

    # Test edge cases
    @test_throws ArgumentError alpinen2(Float64[])
    @test_throws ArgumentError alpinen2([-1.0, 1.0])
    @test_throws ArgumentError alpinen2([11.0, 1.0])
    @test isnan(alpinen2([NaN, 1.0]))
    @test isfinite(alpinen2(tf.meta[:lb](n)))
    @test isfinite(alpinen2(tf.meta[:ub](n)))
    @test isfinite(alpinen2(fill(1e-308, n)))

    # Test optimization with Fminbox(LBFGS()) using gradient information
    lb = tf.meta[:lb](n)  # [0.0, 0.0]
    ub = tf.meta[:ub](n)  # [10.0, 10.0]
    start_points = [
        tf.meta[:start](n),  # [7.0, 7.0]
        [6.0, 6.0],
        [8.0, 8.0]
    ]
    success = false
    result = nothing
    for start in start_points
        result = optimize(tf.f, tf.gradient!, lb, ub, start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, iterations=1000))
        if Optim.converged(result) && isapprox(Optim.minimum(result), -2.8081311800070053^n, atol=1e-2)
            success = true
            break
        end
    end
    @test success
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ -2.8081311800070053^n atol=1e-2
    @test all(abs.(Optim.minimizer(result) .- tf.meta[:min_position](n)) .< 1e-2)
end