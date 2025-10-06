# test/mishra4_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "mishra4" begin
    tf = MISHRA4_FUNCTION

    @test tf.meta[:name] == "mishra4"
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
    @test f_start ≈ 0.0 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈  [-9.94114880716358, -9.999999996365672] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-3  # Looser atol due to approx pos

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-10.0, -10.0]
    @test ub ≈ [10.0, 10.0]

    # Extra point
    test_pt = [-5.0, -5.0]
    @test tf.f(test_pt) ≈ 0.8855 atol=1e-3
end