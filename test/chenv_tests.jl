# test/chenv_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "chenv" begin
    tf = CHENV_FUNCTION

    @test tf.meta[:name] == "chenv"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable") 
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    @test !has_property(tf, "scalable")
    @test length(tf.meta[:properties]) == 6

    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0])  # Wrong dimension
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])  # Wrong dimension

    start_point = tf.meta[:start]()
    @test start_point ≈ [400.0, 400.0]  atol=1e-6
    f_start = tf.f(start_point)
    @test f_start ≈   -1000.0000000000001 atol=1e-3  # Computed via REPL: chenv([0.0, 0.0])

    min_pos = tf.meta[:min_position]()
    @test min_pos ≈   [0.500000000004, 0.500000000004]  atol=1e-6
    f_min = tf.f(min_pos)
    @test f_min ≈ tf.meta[:min_value]() atol=1e-8

    lb, ub = tf.meta[:lb](), tf.meta[:ub]()
    @test lb ≈ [-500.0, -500.0]
    @test ub ≈ [500.0, 500.0]

    # Extra test point
    test_pt = [1.0, 1.0]
    @test tf.f(test_pt) ≈  -1000.001444443247 	atol=1e-3  # Computed via REPL: chenv([1.0, 1.0])
    
  
    
    # Test NaN/Inf handling
    @test isnan(tf.f([NaN, 1.0]))
    @test isinf(tf.f([Inf, 1.0]))
    @test all(isnan.(tf.grad([NaN, 1.0])))
    @test all(isinf.(tf.grad([Inf, 1.0])))
end