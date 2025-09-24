# test/corana_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "corana" begin
    tf = CORANA_FUNCTION

    @test tf.meta[:name] == "corana"
    @test has_property(tf, "bounded")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 4

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start](2)
    @test start_point ≈ [1.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 135.510375 atol=1e-3

    min_pos = tf.meta[:min_position](2)
    @test min_pos ≈ [0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](2) atol=1e-8

    lb, ub = tf.meta[:lb](2), tf.meta[:ub](2)
    @test lb ≈ [-500.0, -500.0]
    @test ub ≈ [500.0, 500.0]

    # Extra point
    test_pt = [0.1, 0.1]
    @test tf.f(test_pt) ≈ 10.01 atol=1e-3
end