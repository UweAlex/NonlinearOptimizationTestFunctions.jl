# test/ripple1_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "ripple1" begin
    tf = RIPPLE1_FUNCTION
    @test tf.meta[:name] == "ripple1"
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "multimodal")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
	println(start_point)
    @test tf.f(start_point) ≈ -1.5556 atol=1e-3  # Corrected expected at [0.5,0.5]
    
    min_pos = tf.meta[:min_position]()
	println(min_pos)
    @test length(min_pos) == 2
    @test all(isapprox.(min_pos, [0.1, 0.1], atol=1e-8))
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    
    # Check gradient at minimum
    grad_at_min = tf.grad(min_pos)
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-8))
    
    # Bounds check
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test length(lb) == 2 == length(ub)
    @test all(isapprox.(lb, [0.0, 0.0], atol=1e-8))
    @test all(isapprox.(ub, [1.0, 1.0], atol=1e-8))
    @test all(start_point .>= lb .+ 1e-10)
    @test all(start_point .<= ub .- 1e-10)
end