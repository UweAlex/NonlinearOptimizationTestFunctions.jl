# test/wayburnseader2_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "wayburnseader2" begin
    tf = WAYBURNSEADER2_FUNCTION
    @test tf.meta[:name] == "wayburnseader2"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 82313.257 atol=1e-3  # Realer Wert für [-5,-5]; war Template-Fehler
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-6  # Atol erhöht für FP (1.56e-8 < 1e-6)
    
    # Extra: Test second minimum
    min_pos2 = [0.425, 1.0]
    @test tf.f(min_pos2) ≈ 0.0 atol=1e-6  # Atol erhöht
    
    # Edge cases (via runtests.jl, but local check)
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, 0.0]))
    @test isinf(tf.f([Inf, 0.0]))
end