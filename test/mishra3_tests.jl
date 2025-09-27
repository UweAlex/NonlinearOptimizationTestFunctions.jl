# test/mishra3_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "mishra3" begin
    tf = MISHRA3_FUNCTION

    @test tf.meta[:name] == "mishra3"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5
    @test tf.meta[:source] == "Mishra (2006f)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 1.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-8.466613775046579, -9.998521308999999] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-6

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-10.0, -10.0]
    @test ub ≈ [10.0, 10.0]

    # Extra point
    test_pt = [-2.0, -2.0]
    @test tf.f(test_pt) ≈ 0.3549 atol=1e-3
end