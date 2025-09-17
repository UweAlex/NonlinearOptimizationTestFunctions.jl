# test/chen_tests.jl
# Purpose: Tests for the Chen V test function in NonlinearOptimizationTestFunctions.
# Last modified: 10 September 2025

using Test, NonlinearOptimizationTestFunctions, Optim

@testset "Chen V Tests" begin
    tf = NonlinearOptimizationTestFunctions.CHEN_FUNCTION
    
    # Test Metadaten
    @test tf.meta[:name] == "chen"
    @test tf.meta[:min_value]() ≈ -2000.0 atol=1e-6
    @test tf.meta[:min_position]() ≈ [0.388888888888889, 0.722222222222222] atol=1e-6
    @test tf.meta[:start]() ≈ [0.01, 0.01] atol=1e-6
    @test tf.meta[:lb]() == [-500.0, -500.0]
    @test tf.meta[:ub]() == [500.0, 500.0]
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"])
    @test tf.meta[:reference] == "[Jamil & Yang (2013): f32], [Naser et al. (2024)], [al-roomi.org]"
    
    # Test Funktionswerte
    @test tf.f(tf.meta[:min_position]()) ≈ -2000.0 atol=1e-6
    @test tf.f([0.0, 0.0]) ≈ -(0.001 / (0.000001 + (-0.1)^2) + 0.001 / (0.000001 + (-1.5)^2)) atol=1e-6  # ≈ -39.874
    
    # Test Edge Cases
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Falsche Dimension
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isfinite(tf.f([1e-308, 1e-308]))
    @test isfinite(tf.f(tf.meta[:lb]()))
    @test isfinite(tf.f(tf.meta[:ub]()))
    
   
end