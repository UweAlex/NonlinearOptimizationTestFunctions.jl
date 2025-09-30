# test/parsopoulos_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "parsopoulos" begin
    tf = PARSOPOULOS_FUNCTION

    @test tf.meta[:name] == "parsopoulos"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "separable")
    @test has_property(tf, "non-convex")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:source] == "Parsopoulos et al., via Jamil & Yang (2013): f85"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 1.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [π/2, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-5.0, -5.0]
    @test ub ≈ [5.0, 5.0]

    # Extra point
    test_pt = [π, 0.0]
    @test tf.f(test_pt) ≈ 1.0 atol=1e-3
end