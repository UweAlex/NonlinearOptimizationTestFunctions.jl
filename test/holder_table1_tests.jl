# test/holder_table1_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "holder_table1" begin
    tf = HOLDER_TABLE1_FUNCTION
    @test tf.meta[:name] == "holder_table1"
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "bounded")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ 0.0 atol=1e-3
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-6
    
    # Check another global minimum
    min_pos_alt = [-8.0550238, 9.6643736]
    @test tf.f(min_pos_alt) ≈ -19.208502 atol=1e-6
    
    # Check gradient at minimum (should be approx zeros)
    grad = tf.grad(min_pos)
    @test all(abs.(grad) .< 1e-3)
end