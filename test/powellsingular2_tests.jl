# test/powellsingular2_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "powellsingular2" begin
    tf = POWELSINGULAR2_FUNCTION
    n = 4

    @test tf.meta[:name] == "powellsingular2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:source] == "Fu et al. (2006)"
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start](n)
    @test start_point ≈ [3.0, -1.0, 0.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 215.0 atol=1e-3

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ [0.0, 0.0, 0.0, 0.0] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ [-4.0, -4.0, -4.0, -4.0]
    @test ub ≈ [5.0, 5.0, 5.0, 5.0]

    # Extra point
    test_pt = [1.0, 1.0, 1.0, 1.0]
    @test tf.f(test_pt) ≈ 122.0 atol=1e-3
end