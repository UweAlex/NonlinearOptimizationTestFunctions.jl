# test/damavandi_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "damavandi" begin
    tf = DAMAVANDI_FUNCTION

    @test tf.meta[:name] == "damavandi"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 149.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [2.0, 2.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [0.0, 0.0]
    @test ub ≈ [14.0, 14.0]

    # Extra point
    test_pt = [4.0, 4.0]
    @test tf.f(test_pt) ≈ 29.0 atol=1e-3
end