# test/schwefel12_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "schwefel12" begin
    tf = SCHWEFE12_FUNCTION
    @test tf.meta[:name] == basename("src/functions/schwefel12.jl")[1:end-3]  # Dynamisch: "schwefel12"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "unimodal")
    
    n = tf.meta[:default_n]  # Verwende default_n für Standard-Tests [RULE_DEFAULT_N]
    @test n >= 2
    
    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)  # Start at zeros
    
    min_pos = tf.meta[:min_position](n)
    @test length(min_pos) == n
    @test all(isapprox.(min_pos, zeros(n), atol=1e-8))  # [RULE_TEST_SYNTAX]
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value](n) atol=1e-8  # Kein Noise, exakte Prüfung
    
    # Extra: Check for n=3
    n_extra = 3
    min_pos_extra = tf.meta[:min_position](n_extra)
    @test tf.f(min_pos_extra) ≈ 0.0 atol=1e-8
end