# test/penholder_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "penholder" begin
    tf = PENHOLDER_FUNCTION

    @test tf.meta[:name] == "penholder"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "non-convex")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 6
    @test tf.meta[:source] == "Mishra (2006f), via Jamil & Yang (2013): f86"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ -1.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [9.646167671043401, 9.646167671043401] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-11.0, -11.0]
    @test ub ≈ [11.0, 11.0]

    # Extra point
    test_pt = [π, π]
    @test tf.f(test_pt) ≈ -0.5164071359758017 atol=1e-3
end