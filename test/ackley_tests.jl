# test/ackley_tests.jl
# Purpose: Deterministische Unit-Tests für die Ackley-Funktion
# 100 % konform mit der 2025-Anleitung – keine Optimierung, keine finite difference

using Test
using NonlinearOptimizationTestFunctions: ACKLEY_FUNCTION, ackley, ackley_gradient

@testset "Ackley Tests" begin
    tf = ACKLEY_FUNCTION

    # ------------------------------------------------------------------
    # Edge Cases
    # ------------------------------------------------------------------
    @test_throws ArgumentError ackley(Float64[])      # leerer Vektor
    @test isnan(ackley([NaN]))
    @test isinf(ackley([Inf]))
    @test isfinite(ackley([1e-308]))

    # ------------------------------------------------------------------
    # Funktionswerte am Minimum und an bekannten Punkten
    # ------------------------------------------------------------------
    @test ackley([0.0])           ≈ 0.0 atol=1e-12
    @test ackley(zeros(10))       ≈ 0.0 atol=1e-12
    @test ackley([1.0, 1.0])      ≈ 3.6253849384403627 atol=1e-10
    @test ackley([0.5, 0.5])      ≈ 4.253654026568412 atol=1e-10

    # ------------------------------------------------------------------
    # Analytischer Gradient am Minimum (muss exakt Null sein)
    # ------------------------------------------------------------------
    @test ackley_gradient(zeros(1))     ≈ [0.0] atol=1e-12
    @test ackley_gradient(zeros(5))     ≈ zeros(5) atol=1e-12

    # Gradient an einem beliebigen Punkt – nur Plausibilität (nicht Null)
    @test !all(iszero, ackley_gradient([1.0, 2.0]))
    @test all(isfinite, ackley_gradient([10.0, -10.0]))

    # ------------------------------------------------------------------
    # In-place Gradient (muss mit out-of-place übereinstimmen)
    # ------------------------------------------------------------------
    for n in (1, 3, 10)
        x = tf.meta[:start](n)
        G = zeros(n)
        tf.gradient!(G, x)
        @test G ≈ ackley_gradient(x) atol=1e-12
    end

    # ------------------------------------------------------------------
    # Metadata – exakt wie in der Funktion definiert
    # ------------------------------------------------------------------
    @test tf.meta[:name] == "ackley"

    # Startpunkt ist fill(16.0, n) → weit weg vom Minimum
    @test all(==(16.0), tf.meta[:start](1))
    @test all(==(16.0), tf.meta[:start](7))

    @test tf.meta[:min_position](1) == [0.0]
    @test tf.meta[:min_position](4) == zeros(4)
    @test tf.meta[:min_value](10) ≈ 0.0 atol=1e-12

    # Bounds
    @test tf.meta[:lb](1) == [-32.768]
    @test tf.meta[:ub](1) == [32.768]
    @test tf.meta[:lb](3, bounds="alternative") == fill(-5.0, 3)
    @test tf.meta[:ub](3, bounds="alternative") == fill(5.0, 3)

    # Properties
    @test "deceptive"     ∈ tf.meta[:properties]
    @test "multimodal"    ∈ tf.meta[:properties]
    @test "non-separable" ∈ tf.meta[:properties]
    @test "differentiable" ∈ tf.meta[:properties]
    @test "scalable"      ∈ tf.meta[:properties]
    @test "bounded"       ∈ tf.meta[:properties]
    @test "continuous"    ∈ tf.meta[:properties]

    # default_n
    @test haskey(tf.meta, :default_n)
    @test tf.meta[:default_n] == 10
end