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
    @test min_pos ≈  [0.6577179521834655, 1.3410086494718647, 0.0621925866606903, -0.9215843284021408, -0.8587539108194528, 0.0398894904746407, -3.3508073710903923, 0.6714854553331792, -3.3960325842653383, 2.381549919707253, -1.3565015163235619, 1.3510478875312162, -3.3405083834260405, 1.8923144784852317, -2.7015951415440593, -0.9050732332838868, -1.677429264374116] atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [0.0; fill(-4.0, 16)]
    @test ub ≈ [4.0; fill(4.0, 16)]

    # Extra point
    test_pt = fill(1.0, 17)
    @test tf.f(test_pt) ≈ 230.8379 atol=1e-3
end