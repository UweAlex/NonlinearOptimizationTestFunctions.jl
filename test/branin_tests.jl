# test/branin_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "branin" begin
    tf = BRANIN_FUNCTION
    @test tf.meta[:name] == "branin"

    x_start = tf.meta[:start]()
    x_min   = tf.meta[:min_position]()
    f_min   = tf.meta[:min_value]()

    @test tf.f(x_start) ≈ 55.602112642270264 atol=1e-10
    @test tf.f(x_min)   ≈ f_min               atol=1e-10

    @test x_start       == [0.0, 0.0]
    @test x_min         ≈ [-π, 12.275]        atol=1e-10
    @test tf.meta[:lb]() == [-5.0, 0.0]
    @test tf.meta[:ub]() == [10.0, 15.0]

    # Edge cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
end