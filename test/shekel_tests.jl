# test/shekel_tests.jl
# Purpose: Tests for the Shekel test function in NonlinearOptimizationTestFunctions.
# Context: Validates metadata, properties, evaluations, and optimization for non-scalable Shekel (n=4 fixed).
# Last modified: October 26, 2025

using Test, NonlinearOptimizationTestFunctions, Optim

@testset "shekel" begin
    tf = SHEKEL_FUNCTION
    @test tf.meta[:name] == "shekel"  # [RULE_NAME_CONSISTENCY]
    
    # Property checks [RULE_PROPERTIES_SOURCE]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "finite_at_inf")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-convex")
    @test has_property(tf, "non-separable")
    
    # Start point evaluation (non-scalable: () -> ...) [RULE_META_CONSISTENCY]
    start_point = tf.meta[:start]()  # Fixed: No (n) call
    @test start_point == [2.0, 2.0, 2.0, 2.0]
    @test length(start_point) == 4
    @test tf.f(start_point) ≈ -0.46329209926592196 atol=1e-3  # Pre-computed value at start
    
    # Minimum validation [RULE_ATOL]
    min_pos = tf.meta[:min_position]()  # Fixed: No (n) call
    @test all(isapprox.(min_pos, [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956], atol=1e-8))
    @test length(min_pos) == 4
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # ≈ -10.536409816692043
    
    # Bounds checks (non-scalable: () -> ...) [RULE_META_CONSISTENCY]
    lb = tf.meta[:lb]()  # Fixed: No (n) call
    ub = tf.meta[:ub]()  # Fixed: No (n) call
    @test lb == [0.0, 0.0, 0.0, 0.0]
    @test ub == [10.0, 10.0, 10.0, 10.0]
    @test length(lb) == length(ub) == 4
    
    # Finite at bounds (since bounded and continuous)
    @test isfinite(tf.f(lb))
    @test isfinite(tf.f(ub))
    
    # Optimization test: For multimodal, check decrease from start and stationarity (local min), not necessarily global [RULE_ATOL]
    @testset "Optimization Tests" begin
        f_start = tf.f(start_point)
        result = optimize(
            tf.f,
            tf.gradient!,  # Use analytical gradient
            start_point,
            LBFGS(),  # Local optimizer
            Optim.Options(f_reltol=1e-6, iterations=1000)
        )
        f_opt = Optim.minimum(result)
        x_opt = Optim.minimizer(result)
        
        # Check decrease from start
        @test f_opt < f_start  # At least improves
        
        # Check stationarity (gradient near zero at found point)
        @test norm(tf.grad(x_opt)) < 1e-3
        
        # For Shekel (multimodal), accept local min near -5.128 (from start [2,2,2,2] basin)
        @test f_opt ≈ -5.128480786627453 atol=0.01  # Known local min value
        
        # Optional: Check position near known local min [1,1,1,1]
        @test all(isapprox.(x_opt, [1.0, 1.0, 1.0, 1.0], atol=0.1))
        
        # Note: Global min requires better start (e.g. [4,4,4,4]) or global optimizer; not enforced here
    end
end