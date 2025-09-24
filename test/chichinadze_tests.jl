# test/chichinadze_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "chichinadze" begin
    tf = CHICHINADZE_FUNCTION

    @test tf.meta[:name] == "chichinadze"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "multimodal")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 20.6053353872 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [6.18986658696568, 0.5] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-30.0, -30.0]
    @test ub ≈ [30.0, 30.0]

    # Extra point
    test_pt = [1.0, 1.0]
    @test tf.f(test_pt) ≈ 7.6053353872 atol=1e-3
end