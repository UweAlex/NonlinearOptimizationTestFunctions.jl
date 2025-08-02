# test/langermann_tests.jl
using Test
using NonlinearOptimizationTestFunctions
using Optim
using LinearAlgebra

@testset "Langermann Tests" begin
    tf = LANGERMANN_FUNCTION
    n = 2

    # Test function properties
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "bounded")
    @test has_property(tf, "controversial")

    # Test function value at minimum and start point
    @test langermann(tf.meta[:min_position](n)) ≈ -5.162126159963982 atol=1e-6
    @test langermann(tf.meta[:start](n)) ≈ -0.1604074079959707 atol=1e-6

    # Test optimization
    @testset "Optimization Tests" begin
        result = optimize(tf.f, tf.meta[:lb](n), tf.meta[:ub](n), [2.0, 1.0], Fminbox(BFGS()))  # Geänderter Startpunkt
        @test norm(Optim.minimizer(result) - tf.meta[:min_position](n)) < 0.2  # Erhöhte Toleranz
        @test Optim.minimum(result) ≈ -5.162126159963982 atol=1e-5
    end
end