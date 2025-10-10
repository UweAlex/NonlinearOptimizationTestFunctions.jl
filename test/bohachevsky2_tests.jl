# test/bohachevsky2_tests.jl
# Purpose: Tests for the Bohachevsky 2 test function in NonlinearOptimizationTestFunctions.
# Context: Verifies function values, metadata, edge cases, and optimization with Optim.jl.
# Last modified: 07 September 2025

using Test
using NonlinearOptimizationTestFunctions: BOHACHEVSKY2_FUNCTION, bohachevsky2
using Optim

@testset "Bohachevsky 2 Tests" begin
    tf = BOHACHEVSKY2_FUNCTION
    n = 2  # Feste Dimension

    # Test Metadaten
    @test tf.meta[:name] == "bohachevsky2"
    @test tf.meta[:start]() == [0.01, 0.01]
    @test tf.meta[:min_position]() == [0.0, 0.0]
    @test tf.meta[:min_value]() == 0.0
    @test tf.meta[:properties] == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]


    # Test Funktionswerte
    @test isapprox(bohachevsky2([0.0, 0.0]), 0.0, atol=1e-6)  # Minimum
    @test isapprox(bohachevsky2([0.01, 0.01]), 0.0003 - 0.3*cos(0.03*π)*cos(0.04*π) + 0.3, atol=1e-6)  # Startpunkt: ~0.004
    @test isapprox(bohachevsky2([-100.0, -100.0]), 10000.0 + 20000.0 - 0.3*cos(3π*(-100.0))*cos(4π*(-100.0)) + 0.3, atol=1e-6)  # Untere Schranke
    @test isapprox(bohachevsky2([100.0, 100.0]), 10000.0 + 20000.0 - 0.3*cos(3π*100.0)*cos(4π*100.0) + 0.3, atol=1e-6)  # Obere Schranke

    # Test Edge Cases
    @test_throws ArgumentError bohachevsky2(Float64[])  # Leerer Vektor
    @test_throws ArgumentError bohachevsky2([1.0, 1.0, 1.0])  # Falsche Dimension
    @test isnan(bohachevsky2([NaN, 1.0]))
    @test isnan(bohachevsky2([1.0, NaN]))
    @test isinf(bohachevsky2([Inf, 1.0]))
    @test isinf(bohachevsky2([1.0, Inf]))
    @test isfinite(bohachevsky2([1e-308, 1e-308]))

    # Test Optimierung mit Optim.jl
    # Verwende Fminbox(LBFGS()) wegen bounded-Eigenschaft und multimodaler Natur
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), tf.meta[:start](), Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    minimizer = Optim.minimizer(result)
    minimum = Optim.minimum(result)
    @test isapprox(minimum, 0.0, atol=1e-2)  # Lockere Toleranz für multimodale Funktion
    @test isapprox(norm(minimizer), 0.0, atol=1e-2)  # Minimizer nahe (0, 0)
end
