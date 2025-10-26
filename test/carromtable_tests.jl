# test/carromtable_tests.jl

using Test, NonlinearOptimizationTestFunctions

@testset "carromtable" begin
    tf = CARROMTABLE_FUNCTION
    @test tf.meta[:name] == "carromtable"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ -0.0 atol=1e-3  # f(0,0) = - (cos0 cos0 exp|1-0/π|)^2 /30 = - (1*1*exp1)^2 /30 ≈ -0.0333
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # ≈ -24.1568155
    
    # Test another global minimum (negative signs)
    min_pos_neg = [-9.646157266348881, -9.646134286497169]
    @test tf.f(min_pos_neg) ≈  -24.15681551650653  atol=1e-8
    
    # Bounds check
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test all(lb .== -10.0)
    @test all(ub .== 10.0)
end