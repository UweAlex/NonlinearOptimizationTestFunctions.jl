# test/devilliersglasser1_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "devilliersglasser1" begin
    tf = DEVILLIERSGLASSER1_FUNCTION

    @test tf.meta[:name] == "devilliersglasser1"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 5
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"

    @test_throws ArgumentError tf.f(Float64[])

    start_point = tf.meta[:start]()
    @test start_point ≈ [1.0, 1.0, 1.0, 1.0] atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈ 105704.20559658577 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈ [60.137, 1.371, 3.112, 1.761] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈  [0.0, 0.0, 0.0, 0.0] 
    @test ub ≈ [500.0, 500.0, 500.0, 500.0]

    # Extra point (positive)
    test_pt = [50.0, 1.5, 3.0, 2.0]
    @test tf.f(test_pt) ≈ 1795.3081024519888 atol=1e-3
    # Negative x2 case (NaN, as adapted)
    neg_pt = [1.0, -1.0, 1.0, 1.0]
    @test isnan(tf.f(neg_pt))
end