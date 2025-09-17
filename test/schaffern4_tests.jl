# test/schaffern4_tests.jl
# Purpose: Tests for the Schaffer N.4 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 03 September 2025

using Test, Optim, Random
using NonlinearOptimizationTestFunctions: SCHAFFERN4_FUNCTION, schaffern4

@testset "Schaffer N.4 Tests" begin
    tf = SCHAFFERN4_FUNCTION

    # More precise values from literature
    PRECISE_MIN_VALUE = 0.292578632035980
    PRECISE_MIN_POS = 1.253131828792882

    # All four equivalent global minima
    GLOBAL_MINIMA = [
        [0.0, PRECISE_MIN_POS],
        [0.0, -PRECISE_MIN_POS], 
        [PRECISE_MIN_POS, 0.0],
        [-PRECISE_MIN_POS, 0.0]
    ]

    @testset "Edge Cases" begin
        @test_throws ArgumentError schaffern4(Float64[])
        @test_throws ArgumentError schaffern4([1.0])  # Wrong dimension
        @test_throws ArgumentError schaffern4([1.0, 2.0, 3.0])  # Wrong dimension
        @test isnan(schaffern4([NaN, 0.0]))
        @test isnan(schaffern4([0.0, NaN]))
        @test isinf(schaffern4([Inf, 0.0]))
        @test isinf(schaffern4([0.0, Inf]))
        @test isfinite(schaffern4([1e-308, 1e-308]))
    end

    @testset "Function Values" begin
        # Test all four global minima
        for global_min in GLOBAL_MINIMA
            calculated_min = schaffern4(global_min)
            @test calculated_min ≈ PRECISE_MIN_VALUE atol=1e-6
        end

        # Test some other known points
        @test schaffern4([0.0, 0.0]) > PRECISE_MIN_VALUE  # Origin should not be minimum

        # When x₁² = x₂², |x₁²-x₂²| = 0, so cos²(sin(0)) = cos²(0) = 1
        # f(x) = 0.5 + (1 - 0.5) / (1 + 0.001(x₁² + x₂²))²
        test_point = [1.0, 1.0]
        expected_val = 0.5 + 0.5 / (1 + 0.001 * 2.0)^2
        @test schaffern4(test_point) ≈ expected_val atol=1e-10
    end

    @testset "Metadaten" begin
        @test tf.meta[:name] == "schaffern4"

        # Test that start point is one of the global minima or close to it
        start_point = tf.meta[:start]()
        min_distance = minimum([norm(start_point - gm) for gm in GLOBAL_MINIMA])
        @test min_distance < 1e-3  # Should be very close to one of the global minima

        @test tf.meta[:min_value]() ≈ PRECISE_MIN_VALUE atol=1e-10
        @test tf.meta[:lb]() == [-100.0, -100.0]
        @test tf.meta[:ub]() == [100.0, 100.0]
        @test tf.meta[:in_molga_smutnicki_2005] == false
        @test Set(tf.meta[:properties]) == Set(["partially differentiable", "multimodal", "non-convex", "non-separable", "bounded", "continuous"])

        # Test dimension checks for meta functions
        @test_throws MethodError tf.meta[:start](1)
        @test_throws MethodError tf.meta[:start](3)
        @test_throws MethodError tf.meta[:min_position](1)
        @test_throws MethodError tf.meta[:min_position](3)
        @test_throws MethodError tf.meta[:lb](1)
        @test_throws MethodError tf.meta[:ub](3)
    end

    @testset "Optimization Tests" begin
        # Test optimization from starting points very close to global minima using NelderMead
        close_starts = [
            [0.001, PRECISE_MIN_POS + 0.001],    # Very close to first global minimum
            [PRECISE_MIN_POS + 0.001, 0.001],    # Very close to third global minimum  
        ]

        for start_point in close_starts
            result = optimize(tf.f, tf.meta[:lb](), tf.meta[:ub](), start_point, Fminbox(NelderMead()), 
                            Optim.Options(f_reltol=1e-6, iterations=5000))
            @test Optim.minimum(result) <= PRECISE_MIN_VALUE + 1e-2
            minimizer = Optim.minimizer(result)
            @test any(isapprox.(norm(minimizer - gm), 0.0, atol=1e-1) for gm in GLOBAL_MINIMA)
        end

        # Test that the function value at global minima is indeed minimal
        for global_min in GLOBAL_MINIMA
            @test schaffern4(global_min) ≈ PRECISE_MIN_VALUE atol=1e-10
        end

        # Test optimization with multiple random restarts
        Random.seed!(42)
        best_found = Inf

        for _ in 1:20  # Try 20 random starting points
            start_point = [4*rand() - 2, 4*rand() - 2]  # Random in [-2, 2]²
            try
                result = optimize(tf.f, tf.meta[:lb](), tf.meta[:ub](), start_point, Fminbox(NelderMead()), 
                                Optim.Options(f_reltol=1e-6, iterations=5000))
                best_found = min(best_found, Optim.minimum(result))
            catch
                # Some starting points might cause issues, skip them
                continue
            end
        end

        # We should find something reasonably close to the global minimum
        @test best_found <= PRECISE_MIN_VALUE + 1e-2
    end

    @testset "Symmetry Tests" begin
        test_points = [[1.0, 2.0], [3.0, 1.0], [2.0, 4.0], [0.5, 1.5]]

        for point in test_points
            x1, x2 = point[1], point[2]
            original_val = schaffern4([x1, x2])
            # Sign symmetry
            @test schaffern4([-x1, x2]) ≈ original_val atol=1e-12
            @test schaffern4([x1, -x2]) ≈ original_val atol=1e-12
            @test schaffern4([-x1, -x2]) ≈ original_val atol=1e-12
            # Swap symmetry (due to abs(x₁² - x₂²))
            @test schaffern4([x2, x1]) ≈ original_val atol=1e-12
        end
    end

    @testset "Special Values Tests" begin
        # Test function values at points where x₁² ≈ x₂²
        epsilon = 1e-8
        near_zero_points = [
            [epsilon, epsilon],
            [1.0, sqrt(1.0 + epsilon)],
            [2.0, sqrt(4.0 + epsilon)]
        ]
        for point in near_zero_points
            @test isfinite(schaffern4(point))
        end

        # Test large values (within bounds, avoiding x₁² ≈ x₂²)
        large_points = [[50.0, 60.0], [-90.0, 80.0], [75.0, -65.0]]
        for point in large_points
            val = schaffern4(point)
            @test isfinite(val)
            @test val > PRECISE_MIN_VALUE  # Should be greater than global minimum
        end
    end

    @testset "Consistency Checks" begin
        # Ensure the claimed minimum position actually gives the minimum value
        claimed_min_pos = tf.meta[:min_position]()
        actual_min_val = schaffern4(claimed_min_pos)
        @test actual_min_val ≈ tf.meta[:min_value]() atol=1e-12

        # Test that no random points give a significantly lower value
        Random.seed!(42)
        for _ in 1:100
            random_point = [200*rand() - 100, 200*rand() - 100]  # Random in [-100, 100]²
            @test schaffern4(random_point) >= PRECISE_MIN_VALUE - 1e-12
        end
    end
end