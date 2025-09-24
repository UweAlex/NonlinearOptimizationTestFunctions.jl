# test/cola_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "cola" begin
    tf = COLA_FUNCTION

    @test tf.meta[:name] == "cola"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ zeros(17) atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 312.4051 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [0.6577,1.3410,0.0622,−0.9216,−0.8587,0.0399,−3.3508,0.6715,−3.3960,2.3815,−1.3565,1.3510,−3.3405,1.8923,−2.7016,−0.9051,−1.6774] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [0.0; fill(-4.0, 16)]
    @test ub ≈ [4.0; fill(4.0, 16)]

    # Extra point
    test_pt = fill(1.0, 17)
    @test tf.f(test_pt) ≈ 230.8379 atol=1e-3
end