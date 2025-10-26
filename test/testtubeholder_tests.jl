# test/testtubeholder_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "testtubeholder" begin
    tf = TESTTUBEHOLDER_FUNCTION
    @test tf.meta[:name] == "testtubeholder"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.0 atol=1e-3  # f(0,0) = -4 * 0 * 1 * exp(1) = 0
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-4  # ≈  10.872299901558  (etwas lockerer atol wg. π/2 approx)
    
    # Test another global minimum (negative)
    min_pos_neg = [-π/2, 0.0]
    @test tf.f(min_pos_neg) ≈  10.872299901558 atol=1e-4
    
    # Bounds check
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test all(lb .== -10.0)
    @test all(ub .== 10.0)
end