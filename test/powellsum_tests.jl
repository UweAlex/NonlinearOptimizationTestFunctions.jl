# test/powellsum_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "powellsum" begin
    tf = POWELLSUM_FUNCTION
    n = 2

    @test tf.meta[:name] == "powellsum"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    @test tf.meta[:source] == "Rahnamyan et al. (2007a)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start](n)
    @test start_point ≈ [0.5, 0.5] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 0.375 atol=1e-3

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ [0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ [-1.0, -1.0]
    @test ub ≈ [1.0, 1.0]

    # Extra point
    test_pt = [0.25, 0.5]
    @test tf.f(test_pt) ≈ 0.1875  atol=1e-3
end