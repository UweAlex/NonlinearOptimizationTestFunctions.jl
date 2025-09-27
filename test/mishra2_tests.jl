# test/mishra2_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "mishra2" begin
    tf = MISHRA2_FUNCTION
    n = 2

    @test tf.meta[:name] == "mishra2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:source] == "Mishra (2006a)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start](n)
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 9.0 atol=1e-3

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ [1.0, 1.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ [0.0, 0.0]
    @test ub ≈ [1.0, 1.0]

    # Extra point
    test_pt = [0.5, 0.5]
    @test tf.f(test_pt) ≈ 3.952847075210474 atol=1e-3
end