# test/ursem4_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "ursem4" begin
    tf = URSEM4_FUNCTION
    @test tf.meta[:name] == "ursem4"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "partially differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "non-separable")
    
    start_point = tf.meta[:start]()
    @test tf.f(start_point) ≈ -1.5 atol=1e-3  # At origin, which is also min
    
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Test gradient at min_pos (defined as [0,0])
    @test all(isapprox.(tf.grad(min_pos), [0.0, 0.0], atol=1e-8))
    
    # Test gradient at another point, e.g., [1.0, 1.0]
    test_point = [1.0, 1.0]
    @test length(tf.grad(test_point)) == 2
end