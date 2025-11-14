# test/pathological_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "pathological" begin
    tf = PATHOLOGICAL_FUNCTION

    @test tf.meta[:name] == "pathological"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 7
    @test tf.meta[:source] == "Rahnamayan et al. (2007a), via Jamil & Yang (2013): f87"

    @test_throws ArgumentError tf.f(Float64[])

    n = 2
    start_point = tf.meta[:start](n)
    
   

    min_pos = tf.meta[:min_position](n)
    @test min_pos ≈ zeros(n) atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8

    lb, ub = tf.meta[:lb](n), tf.meta[:ub](n)
    @test lb ≈ -100 * ones(n)
    @test ub ≈ 100 * ones(n)

    # Extra point
    test_pt = [1.0, 1.0]
    @test tf.f(test_pt) ≈ 0.3424 atol=1e-3
end