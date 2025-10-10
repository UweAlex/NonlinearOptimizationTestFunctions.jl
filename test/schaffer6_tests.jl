# test/schaffer6_tests.jl
# Purpose: Tests for the Schaffer6 function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: September 09, 2025

using Test, NonlinearOptimizationTestFunctions

@testset "schaffer6" begin
    tf = SCHAFFER6_FUNCTION
    func_name = basename("src/functions/schaffer6.jl")[1:end-3]

    @test tf.meta[:name] == func_name

    # Properties
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")

    # Edge Cases
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    @test isnan(tf.f(fill(NaN, 2)))
    @test tf.f(fill(Inf, 2)) ≈ 0.5 atol=1e-8
    @test isfinite(tf.f(fill(1e-308, 2)))

    # Function Values
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.9737845 atol=1e-3

    min_pos = tf.meta[:min_position]()
    @test all(isapprox.(min_pos, [0.0, 0.0], atol=1e-8))
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8

    # Gradient
    @test all(isapprox.(tf.grad(min_pos), [0.0, 0.0], atol=1e-8))

    # Metadata
    @test tf.meta[:start]() == [1.0, 1.0]
    @test tf.meta[:lb]() == [-100.0, -100.0]
    @test tf.meta[:ub]() == [100.0, 100.0]
end