# test/deckkersaarts_tests.jl
# Purpose: Tests for the Deckkers-Aarts test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization for deckkersaarts.jl.
# Last modified: 17 August 2025

using Test
using NonlinearOptimizationTestFunctions: DECKKERSAARTS_FUNCTION, deckkersaarts
using Optim

@testset "DeckkersAarts Tests" begin
    tf = DECKKERSAARTS_FUNCTION
    n = 2

    # Test Metadaten
    @test tf.meta[:name] == "deckkersaarts"
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])
    @test tf.meta[:in_molga_smutnicki_2005] == false
    @test tf.meta[:start](n) == [0.0, 10.0]
    @test tf.meta[:lb](n) == [-20.0, -20.0]
    @test tf.meta[:ub](n) == [20.0, 20.0]
    @test tf.meta[:min_value] ≈ -24776.51834228699 atol=1e-6

    # Test Funktionswerte
    start = tf.meta[:start](n)
    @test deckkersaarts(start) ≈ -8900.0 atol=1e-6  # f([0,10]) = -8900.0

    # Test globales Minimum (beide Minima)
    min_pos1 = [0.0, 14.945108]
    min_pos2 = [0.0, -14.945108]
    @test deckkersaarts(min_pos1) ≈ -24776.51834228699 atol=1e-5
    @test deckkersaarts(min_pos2) ≈ -24776.51834228699 atol=1e-5
    @test tf.meta[:min_position](n) ≈ min_pos1 atol=1e-6

    # Test Edge Cases
    @test_throws ArgumentError deckkersaarts(Float64[])  # Leerer Vektor
    @test_throws ArgumentError deckkersaarts([1.0])  # Falsche Dimension (n=1)
    @test_throws ArgumentError deckkersaarts([1.0, 2.0, 3.0])  # Falsche Dimension (n=3)
    @test isnan(deckkersaarts([NaN, 0.0]))
    @test isnan(deckkersaarts([0.0, NaN]))
    @test isinf(deckkersaarts([Inf, 0.0]))
    @test isinf(deckkersaarts([0.0, Inf]))
    @test isfinite(deckkersaarts([1e-308, 1e-308]))  # Kleine Eingaben
    @test isfinite(deckkersaarts(tf.meta[:lb](n)))  # Untere Schranke
    @test isfinite(deckkersaarts(tf.meta[:ub](n)))  # Obere Schranke

    # Test Optimierung mit Optim.jl (L-BFGS)
    result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6, iterations=1000))
    found_min = Optim.minimizer(result)
    found_value = Optim.minimum(result)
    # Prüfe, ob das gefundene Minimum einem der globalen Minima nahe ist
    @test any(min_pos -> isapprox(found_min, min_pos, atol=0.1), [min_pos1, min_pos2])
    @test found_value ≈ -24776.51834228699 atol=0.1
end