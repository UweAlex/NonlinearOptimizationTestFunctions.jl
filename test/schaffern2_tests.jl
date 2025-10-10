# test/schaffern2_tests.jl
# Purpose: Tests for the Schaffer N.2 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 27 August 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SCHAFFERN2_FUNCTION, schaffern2

@testset "Schaffer N.2 Tests" begin
    tf = SCHAFFERN2_FUNCTION

    # Edge Cases
    @test_throws ArgumentError schaffern2(Float64[])
    @test_throws ArgumentError schaffern2([1.0])  # Wrong dimension
    @test_throws ArgumentError schaffern2([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(schaffern2([NaN, 0.0]))
    @test isnan(schaffern2([0.0, NaN]))
    @test isinf(schaffern2([Inf, 0.0]))
    @test isinf(schaffern2([0.0, Inf]))
    @test isfinite(schaffern2([1e-308, 1e-308]))

    # Function values
    @test schaffern2(tf.meta[:min_position]()) ≈ tf.meta[:min_value]() atol=1e-10
    @test schaffern2(tf.meta[:start]()) ≈ 0.0 atol=1e-10  # Start is at minimum

    # Test specific values
    # When x1 = x2 = 1.0: sin²(1² - 1²) = sin²(0) = 0
    # f([1,1]) = 0.5 + (0 - 0.5) / (1 + 0.001*2)² = 0.5 - 0.5/1.002² ≈ 0.001994
    @test schaffern2([1.0, 1.0]) ≈ 0.5 - 0.5/(1.002)^2 atol=1e-6

    @test schaffern2([10.0, 0.0]) > 0.0  # Should be positive

    # Metadata
    @test tf.meta[:name] == "schaffern2"
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [0.0, 0.0] atol=1e-6
    @test tf.meta[:min_value]() ≈ 0.0 atol=1e-10
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])

    # Test dimension checks for meta functions
    @test_throws MethodError tf.meta[:start](1)
    @test_throws MethodError tf.meta[:start](3)
    @test_throws MethodError tf.meta[:min_position](1)
    @test_throws MethodError tf.meta[:min_position](3)
    @test_throws MethodError tf.meta[:lb](1)
    @test_throws MethodError tf.meta[:ub](3)

    # Optimization tests
    @testset "Optimization Tests" begin
        Random.seed!(1234)
        # Test from slightly perturbed position
        start = tf.meta[:min_position]() + 0.01 * randn(2)
        result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-8, g_tol=1e-8, iterations=1000))
        @test Optim.minimum(result) ≈ tf.meta[:min_value]() atol=1e-6
        @test Optim.minimizer(result) ≈ tf.meta[:min_position]() atol=1e-3
    end

    # Test symmetry properties
    @testset "Symmetry Tests" begin
        test_points = [[1.0, 2.0], [3.0, -1.0], [-2.0, 4.0]]
        for point in test_points
            x1, x2 = point[1], point[2]
            # Test sign symmetry: f(-x1, -x2) = f(x1, x2)
            @test schaffern2([x1, x2]) ≈ schaffern2([-x1, -x2]) atol=1e-10
            # Test parameter symmetry: f(x1, x2) = f(x2, x1) because sin²(x1² - x2²) = sin²(x2² - x1²)
            @test schaffern2([x1, x2]) ≈ schaffern2([x2, x1]) atol=1e-10
        end
    end

    # Additional boundary behavior tests
    @testset "Boundary Behavior Tests" begin
        # Test that function approaches 0.5 as coordinates get very large
        large_val = 100.0
        result = schaffern2([large_val, large_val])
        @test result < 0.5  # Should be less than 0.5 but close to it
        @test result > 0.0  # Should be positive

        # Test some known properties of the function
        # At origin, should be exactly 0.0
        @test schaffern2([0.0, 0.0]) ≈ 0.0 atol=1e-12

        # Function should be bounded between 0 and 1 (approximately)
        Random.seed!(1234)
        test_random_points = [randn(2) * 10 for _ in 1:100]
        for point in test_random_points
            val = schaffern2(point)
            @test val >= -0.1  # Allow small negative due to numerical precision
            @test val <= 1.1   # Allow slightly above 1 due to numerical precision
        end
    end
end