# test/bohachevsky1_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "bohachevsky1" begin
    tf = BOHACHEVSKY1_FUNCTION
    n = 2  # Default for scalable

    @test tf.meta[:name] == "bohachevsky1"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "scalable")
    @test has_property(tf, "separable")
    @test !has_property(tf, "non-separable")


    @test_throws ArgumentError tf.f(Float64[1.0])  # n=1

    start_point = tf.meta[:start](n)
    @test start_point ≈ [1.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 3.6 atol=1e-6

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ [0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-6

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ [-100.0, -100.0]
    @test ub ≈ [100.0, 100.0]

    # Extra point for n=3
    test_pt = [1.0, 1.0, 1.0]
    @test tf.f(test_pt) ≈ 7.2 atol=1e-6  # 3.6 * 2
end