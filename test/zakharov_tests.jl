# test/zakharov_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "zakharov" begin
    tf = ZAKHAROV_FUNCTION
    @test tf.meta[:name] == "zakharov"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    
    n = tf.meta[:default_n]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 1.0)
    
    min_pos = tf.meta[:min_position](n)
    @test tf.f(min_pos) ≈ tf.meta[:min_value](n) atol=1e-8
    
    # Edge cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f(fill(NaN, n)))
    @test isinf(tf.f(fill(Inf, n)))
    @test isfinite(tf.f(fill(1e-308, n)))
    
    # Additional function value test
    @test tf.f(start_point) ≈ 9.3125 atol=1e-6
end