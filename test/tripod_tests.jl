# test/tripod_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "tripod" begin
    tf = TRIPOD_FUNCTION
    @test tf.meta[:name] == "tripod"  # Hartkodiert [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "partially differentiable")
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test all(start_point .== [0.0, 0.0])
    @test tf.f(start_point) == 102.0  # Exact value at start for verification
    
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test all(isapprox.(min_pos, [0.0, -50.0], atol=1e-10))
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # [RULE_TEST_SYNTAX]
    
    # Extra: Gradient at minimum should be zero (subgradient)
    @test all(isapprox.(tf.grad(min_pos), [0.0, 0.0], atol=1e-8))
    
    # Extra: Check at another point (e.g., local minimum? but skip full, just bounds)
    @test all(tf.meta[:lb]() .<= start_point .<= tf.meta[:ub]())
end