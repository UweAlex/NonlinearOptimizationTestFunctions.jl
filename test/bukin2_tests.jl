# test/bukin2_tests.jl
# Purpose: Tests for the Bukin 2 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization with Optim.jl.
# Last modified: 07 September 2025, 1:30 PM CEST

using Test
using NonlinearOptimizationTestFunctions: BUKIN2_FUNCTION, bukin2, bukin2_gradient
using Optim

@testset "Bukin 2 Tests" begin
    tf = BUKIN2_FUNCTION
    n = 2  # Feste Dimension

    # Test Metadaten
    @test tf.meta[:name] == "bukin2"
    @test tf.meta[:start]() == [-7.5, 0.0]
    @test tf.meta[:min_position]() == [-10.0, 0.0]
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:properties] == Set(["bounded","continuous", "differentiable", "multimodal"])
    @test tf.meta[:lb]() == [-15.0, -3.0]
    @test tf.meta[:ub]() == [-5.0, 3.0]
    @test tf.meta[:in_molga_smutnicki_2005] == false

    # Test Funktionswerte
    @test isapprox(bukin2([-10.0, 0.0]), 0.0, atol=1e-6)  # Minimum
    @test isapprox(bukin2([-7.5, 0.0]), 19.203125, atol=1e-6)  # Startpunkt: 100 * (0 - 0.5625 + 1)^2 + 0.01 * 6.25
    @test isapprox(bukin2([-15.0, -3.0]), 1806.5, atol=1e-6)  # Untere Schranke
    @test isapprox(bukin2([-5.0, 3.0]), 1406.5, atol=1e-6)  # Obere Schranke

    # Test Edge Cases
    @test_throws ArgumentError bukin2(Float64[])  # Leerer Vektor
    @test_throws ArgumentError bukin2([1.0, 1.0, 1.0])  # Falsche Dimension
    @test isnan(bukin2([NaN, 1.0]))
    @test isnan(bukin2([1.0, NaN]))
    @test isinf(bukin2([Inf, 1.0]))
    @test isinf(bukin2([1.0, Inf]))
    @test isfinite(bukin2([1e-308, 1e-308]))

    # Test Gradient am Minimum
    @test isapprox(norm(bukin2_gradient([-10.0, 0.0])), 0.0, atol=1e-6)  # Gradient am Minimum

    # Test Optimierung mit Optim.jl
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), tf.meta[:start](), Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    minimizer = Optim.minimizer(result)
    minimum = Optim.minimum(result)
    @test isapprox(norm(minimizer - [-10.0, 0.0]), 0.0, atol=1e-3)  # Minimizer nahe dem Minimum
    @test isapprox(minimum, 0.0, atol=1e-6)  # Funktionswert am Minimum
end