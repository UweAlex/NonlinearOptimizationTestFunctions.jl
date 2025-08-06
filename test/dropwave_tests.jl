# test/dropwave_tests.jl
# Purpose: Tests for the Drop-Wave function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 06 August 2025

using Test, Optim
using NonlinearOptimizationTestFunctions: DROPWAVE_FUNCTION, dropwave
using ForwardDiff
using Random

@testset "Drop-Wave Tests" begin
    tf = DROPWAVE_FUNCTION
    n = 2  # Drop-Wave ist nur für n=2 definiert

    # Edge Cases
    @test_throws ArgumentError dropwave(Float64[])
    @test isnan(dropwave(fill(NaN, n)))
    @test isinf(dropwave(fill(Inf, n)))
    @test isfinite(dropwave(fill(1e-308, n)))

    # Metadaten-Tests
    @test tf.meta[:name] == "dropwave"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ -1.0 atol=1e-6
    @test tf.meta[:lb](n) == [-5.12, -5.12]
    @test tf.meta[:ub](n) == [5.12, 5.12]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])

    # Funktionswert am Minimum
    @test dropwave(tf.meta[:min_position](n)) ≈ -1.0 atol=1e-6

    # Funktionswert am Startpunkt
    x_start = tf.meta[:start](n)  # [1.0, 1.0]
    r = sqrt(2.0)  # sqrt(1^2 + 1^2)
    expected_value = -(1 + cos(12 * r)) / (0.5 * 2 + 2)
    @test dropwave(x_start) ≈ expected_value atol=1e-6

    # Gradiententests
    @testset "Gradient Tests" begin
        # Gradient am Minimum sollte [0, 0] sein
        @test tf.grad(tf.meta[:min_position](n)) ≈ [0.0, 0.0] atol=1e-6

        # Vergleich mit ForwardDiff an zufälligen Punkten
        Random.seed!(1234)
        lb = tf.meta[:lb](n)
        ub = tf.meta[:ub](n)
        for _ in 1:5
            x = lb + (ub - lb) .* rand(n)
            programmed_grad = tf.grad(x)
            ad_grad = ForwardDiff.gradient(tf.f, x)
            @test programmed_grad ≈ ad_grad atol=0.001
        end
    end

    # Optimierungstest mit L-BFGS
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Leichte Störung für multimodale Funktion
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=1e-3
    end
end