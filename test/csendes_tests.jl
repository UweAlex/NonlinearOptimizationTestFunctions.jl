# test/csendes_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "csendes" begin
    tf = CSENDES_FUNCTION

    @test tf.meta[:name] == "csendes"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test length(tf.meta[:properties]) == 6

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start](2)
    @test start_point ≈ [0.5, 0.5] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 1.2397 atol=1e-3

    min_pos = tf.meta[:min_position](2)
    @test min_pos ≈ [0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](2) atol=1e-8

    lb, ub = tf.meta[:lb](2), tf.meta[:ub](2)
    @test lb ≈ [-1.0, -1.0]
    @test ub ≈ [1.0, 1.0]

    # Extra point
    test_pt = [-0.5, -0.5]
    @test tf.f(test_pt) ≈ 0.7603 atol=1e-3
end