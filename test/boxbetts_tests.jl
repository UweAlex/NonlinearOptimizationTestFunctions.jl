# test/boxbetts_tests.jl
# Purpose: Tests for the Box-Betts Quadratic Sum function in NonlinearOptimizationTestFunctions.
# Last modified: 09 September 2025, 10:25 PM CEST
# Source: MVF - Multivariate Test Functions Library in C, Ernesto P. Adorio, Revised January 14, 2005

using Test, NonlinearOptimizationTestFunctions, Optim

@testset "Box-Betts Quadratic Sum Tests" begin
    tf = NonlinearOptimizationTestFunctions.BOXBETTS_FUNCTION
    
    # Metadaten-Tests
    @test tf.meta[:name] == "boxbetts"
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:min_position]() == [1.0, 10.0, 1.0]
    @test tf.meta[:start]() == [1.0, 10.0, 1.0]
    @test tf.meta[:lb]() == [0.9, 9.0, 0.9]
    @test tf.meta[:ub]() == [1.2, 11.2, 1.2]
    @test tf.meta[:properties] == Set(["continuous", "differentiable", "multimodal"])
    @test tf.meta[:in_molga_smutnicki_2005] == false
    
    # Funktionswert-Tests
    @test tf.f([1.0, 10.0, 1.0]) ≈ 0.0 atol=1e-6  # Minimum
    @test tf.f([1.0, 10.0, 1.0]) ≈ tf.f(tf.meta[:start]()) atol=1e-6
    
    # Edge Cases
    @test_throws ArgumentError tf.f(Float64[])  # Leerer Vektor
    @test_throws ArgumentError tf.f([1.0, 10.0])  # Falsche Dimension
    @test isnan(tf.f([NaN, 10.0, 1.0]))  # NaN-Eingabe
    @test isfinite(tf.f([0.9, 9.0, 0.9]))  # Untere Schranke
    @test isfinite(tf.f([1.2, 11.2, 1.2]))  # Obere Schranke
    @test isfinite(tf.f([1e-308, 9.0, 0.9]))  # Sehr kleiner Wert
    
    # Optimierungstest mit Fminbox(LBFGS())
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), tf.meta[:start](), Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test Optim.converged(result)
    @test Optim.minimum(result) ≈ 0.0 atol=1e-6
    @test Optim.minimizer(result) ≈ [1.0, 10.0, 1.0] atol=1e-3
end