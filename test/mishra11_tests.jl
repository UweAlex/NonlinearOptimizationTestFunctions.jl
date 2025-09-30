# test/mishra11_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "mishra11" begin
    tf = MISHRA11_FUNCTION

    @test tf.meta[:name] == "mishra11"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 7
    @test tf.meta[:source] == "Mishra (2006f), via Jamil & Yang (2013): f84"

    @test_throws ArgumentError tf.f(Float64[])

    n = 2
    start_point = tf.meta[:start](n)
    @test start_point ≈ 0.5 * ones(n) atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 0.0 atol=1e-3

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ ones(n) atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ zeros(n)
    @test ub ≈ 10 * ones(n)

    # Extra point
    test_pt = [2.0, 1.0]
    @test tf.f(test_pt) ≈ 0.00736 atol=1e-3
end