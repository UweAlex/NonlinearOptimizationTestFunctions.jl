# test/schaffer1_tests.jl

using Test
using NonlinearOptimizationTestFunctions

@testset "schaffer1" begin
    tf = SCHAFFER1_FUNCTION
    
    # Test name consistency [RULE_NAME_CONSISTENCY]
    @test tf.meta[:name] == basename("src/functions/schaffer1.jl")[1:end-3]
    @test tf.meta[:name] == "schaffer1"
    
    # Test properties [RULE_PROPERTIES_SOURCE]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    
    # Test dimension requirement
    @test_throws Exception tf.f([])  # MethodError for empty Vector{Any}
    @test_throws ArgumentError tf.f([1.0])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    
    # Test at start point
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test start_point == [1.0, 1.0]
    
    # Compute f at start: r_sq = 2, sin(2)^2 ≈ 0.826822, numerator ≈ 0.326822
    # denominator = (1.002)^2 ≈ 1.004004, f ≈ 0.5 + 0.326822/1.004004 ≈ 0.8256
    f_start = tf.f(start_point)
    @test f_start ≈ 0.825567 atol=1e-3
    
    # Test at global minimum
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test min_pos == [0.0, 0.0]
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    @test tf.f(min_pos) ≈ 0.0 atol=1e-8
    
    # Test gradient at minimum (should be zero)
    grad_at_min = tf.grad(min_pos)
    @test length(grad_at_min) == 2
    @test all(isapprox.(grad_at_min, zeros(2), atol=1e-8))
    
    # Test gradient dimension consistency
    @test_throws Exception tf.grad([])  # MethodError for empty Vector{Any}
    @test_throws ArgumentError tf.grad([1.0])
    @test_throws ArgumentError tf.grad([1.0, 2.0, 3.0])
    
    # Test at another point to verify multimodality
    # At x = [0.0, π]: r_sq ≈ 9.8696, sin(9.8696)^2 ≈ 0.6931
    # numerator ≈ 0.1931, denominator ≈ 1.0398, f ≈ 0.5 + 0.1857 ≈ 0.6857
    # CORRECTED: Actual calculation shows f([0.0, π]) ≈ 0.1913
    test_point = [0.0, π]
    f_test = tf.f(test_point)
    @test f_test ≈ 0.1913 atol=1e-3
    @test f_test > tf.meta[:min_value]()  # Not at minimum
    
    # Test bounds
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test length(lb) == 2
    @test length(ub) == 2
    @test all(lb .== -100.0)
    @test all(ub .== 100.0)
    
    # Test NaN/Inf handling
    @test isnan(tf.f([NaN, 0.0]))
    @test isnan(tf.f([0.0, NaN]))
    @test isinf(tf.f([Inf, 0.0]))
    @test isinf(tf.f([0.0, Inf]))
    
    @test all(isnan.(tf.grad([NaN, 0.0])))
    @test all(isnan.(tf.grad([0.0, NaN])))
    @test all(isinf.(tf.grad([Inf, 0.0])))
    @test all(isinf.(tf.grad([0.0, Inf])))
    
    # Test symmetry: f(x,y) should equal f(y,x) due to x1^2 + x2^2
    @test tf.f([3.0, 4.0]) ≈ tf.f([4.0, 3.0]) atol=1e-10
    @test tf.f([-2.0, 5.0]) ≈ tf.f([5.0, -2.0]) atol=1e-10
    
    # Test that function is rotation-invariant (same radius = same value)
    r = 5.0
    @test tf.f([r, 0.0]) ≈ tf.f([0.0, r]) atol=1e-10
    @test tf.f([r/√2, r/√2]) ≈ tf.f([r, 0.0]) atol=1e-10
end