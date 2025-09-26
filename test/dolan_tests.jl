# test/dolan_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "dolan" begin
    tf = DOLAN_FUNCTION

    @test tf.meta[:name] == "dolan"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "controversial")
    @test !has_property(tf, "scalable")
    @test !has_property(tf, "scalable")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0, 0.0, 0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ -1.0 atol=1e-8

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [98.964258312237106, 100.0, 100.0, 99.224323672554704, -0.249987527588471] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-100.0, -100.0, -100.0, -100.0, -100.0]
    @test ub ≈ [100.0, 100.0, 100.0, 100.0, 100.0]

    # Extra point
    test_pt = [1.0, 1.0, 1.0, 1.0, 1.0]
    @test tf.f(test_pt) ≈ -1.0820585716054931 atol=1e-8
end