# test/powell_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "powell" begin
    tf = POWELL_FUNCTION
    @test tf.meta[:name] == "powell"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 215.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8

    # Edge cases
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Wrong dimension
    @test isnan(tf.f([NaN, 0.0, 0.0, 0.0]))
    @test isinf(tf.f([Inf, 0.0, 0.0, 0.0]))
    @test isfinite(tf.f([1e-308, 1e-308, 1e-308, 1e-308]))

    # Additional function value tests
    @test tf.meta[:min_value]() == 0.0
    @test tf.meta[:min_position]() == [0.0, 0.0, 0.0, 0.0]
    @test tf.meta[:start]() == [3.0, -1.0, 0.0, 1.0]
    @test tf.meta[:lb]() == fill(-5.0, 4)
    @test tf.meta[:ub]() == fill(5.0, 4)
    @test tf.f([0.0, 0.0, 0.0, 0.0]) == 0.0
    @test isapprox(tf.f([3.0, -1.0, 0.0, 1.0]), 215.0, atol=1e-6)
    @test isapprox(tf.grad([1.0, 1.0, 1.0, 1.0]), [22.0, 216.0, 8.0, 0.0], atol=1e-6)
    @test isapprox(tf.grad([0.0, 0.0, 0.0, 0.0]), [0.0, 0.0, 0.0, 0.0], atol=1e-6)
    @test isapprox(tf.grad([1.0, 1.0, 1.0, 1.0]), ForwardDiff.gradient(tf.f, [1.0, 1.0, 1.0, 1.0]), atol=1e-6)
end