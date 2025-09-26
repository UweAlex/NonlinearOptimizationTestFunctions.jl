# test/rana_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "rana" begin
    tf = RANA_FUNCTION

    @test tf.meta[:name] == "rana"
    @test has_property(tf, "multimodal")
    @test has_property(tf, "partially differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.start()
    @test start_point ≈ [0.0, 0.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 0.454648713413 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [-500.0, -499.0733150925747] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.lb(), tf.ub()
    @test lb ≈ [-500.0, -500.0]
    @test ub ≈ [500.0, 500.0]

    # Extra point
    test_pt = [1.0, 1.0]
    @test tf.f(test_pt) ≈ 0.263085434978 atol=1e-3
    # Non-diff (if applicable): NaN for gradient where a=0 or b=0
    @test all(isnan.(rana_gradient([-0.5, -0.5])))
end