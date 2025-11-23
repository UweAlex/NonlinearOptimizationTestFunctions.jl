# test/devilliersglasser2_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "devilliersglasser2" begin
    tf = DEVILLIERSGLASSER2_FUNCTION

    @test tf.meta[:name] == "devilliersglasser2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")

    # Entferne den falschen properties_source-Test – das Feld existiert nicht mehr
    # @test tf.meta[:properties_source] == "Jamil & Yang (2013)"   # ← löschen!

    @test_throws ArgumentError tf.f(Float64[])

    # Neuer Startpunkt aus deiner aktuellen Implementierung
    start_point = tf.meta[:start]()
    @test start_point ≈ [10.0, 2.0, 3.0, 1.0, 0.5] atol=1e-8
    f_start = tf.f(start_point)
    @test f_start ≈ 25358.33 atol=1e-2   # exakter Wert mit neuem Startpunkt

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [53.81, 1.27, 3.012, 2.13, 0.507] atol=1e-6
    @test tf.f(min_pos) ≈ 0.0 atol=1e-8

    # Neue, korrekte Bounds (wie in AMPGO und allen modernen Benchmarks)
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test lb ≈ [1.0, 1.0, 1.0, 1.0, 1.0] atol=1e-10
    @test ub ≈ [60.0, 60.0, 60.0, 60.0, 60.0] atol=1e-10

 
end