# test/leon_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "leon" begin
    tf = LEON_FUNCTION

    @test tf.meta[:name] == "leon"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "unimodal")
    @test has_property(tf, "non-separable")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5
    @test tf.meta[:source] == "Lavi and Vogel (1966)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 1.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [1.0, 1.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-1.2, -1.2]
    @test ub ≈ [1.2, 1.2]

    # Extra point
    test_pt = [0.5, 0.5]
    @test tf.f(test_pt) ≈ 6.5 atol=1e-3
end