# test/devilliersglasser2_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "devilliersglasser2" begin
    tf = DEVILLIERSGLASSER2_FUNCTION

    @test tf.meta[:name] == "devilliersglasser2"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test !has_property(tf, "scalable")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [10.0, 1.0, 1.0, 1.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 72673.0977 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [53.81, 1.27, 3.012, 2.13, 0.507] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [0.0, 0.0, 0.0, 0.0, 0.0]
    @test ub ≈ [500.0, 500.0, 500.0, 500.0, 500.0]

    # Extra point
    test_pt = [0.0, 0.0, 0.0, 0.0, 0.0]
    @test tf.f(test_pt) ≈ 69849.0641 atol=1e-3
end