# test/paviani_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "paviani" begin
    tf = PAVIANI_FUNCTION

    @test tf.meta[:name] == "paviani"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "non-convex")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:source] == "Himmelblau (1972), via Jamil & Yang (2013): f88"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ fill(5.0, 10) atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 12.972 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ fill(9.350266, 10) atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ fill(2.001, 10)
    @test ub ≈ fill(9.999, 10)

    # Extra point
    test_pt = fill(9.0, 10)
    @test tf.f(test_pt) ≈ -43.134 atol=1e-3
end