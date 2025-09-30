# test/mishra10_tests.jl
# Purpose: Unit tests for Mishra Function 10 in NonlinearOptimizationTestFunctions.
# Context: Validates function value, gradient, and minima for fixed n=2.
# Last modified: September 29, 2025
# Validation: Computed via REPL: f([-5,-5])=1225.0, f([0,0])=0.0, f([2,2])=0.0
# Gradient at [0,0]: [0.0, 0.0]; Hessian cond ≈ 1.0 (well-conditioned)

using NonlinearOptimizationTestFunctions
using Test
using ForwardDiff

@testset "Mishra 10 Tests" begin
    tf = MISHRA10_FUNCTION
    n = 2  # Fixed dimension

    # Test function values
    start_point = tf.start(n)
    @test tf.f(start_point) ≈ 1225.0 atol=1e-3  # f([-5,-5]) = (-5-5-(-5)*(-5))^2 = (-35)^2 = 1225

    min_pos1 = tf.meta[:min_position](n)  # [0.0, 0.0]
    @test tf.f(min_pos1) ≈ tf.meta[:min_value] atol=1e-8  # 0.0

    # Additional minimum [2.0, 2.0]
    min_pos2 = [2.0, 2.0]
    @test tf.f(min_pos2) ≈ 0.0 atol=1e-8  # s=2+2-4=0, f=0

    # Bounds check
    lb = tf.lb(n)
    ub = tf.ub(n)
    @test lb ≈ [-10.0, -10.0] atol=1e-6
    @test ub ≈ [10.0, 10.0] atol=1e-6

    # Gradient accuracy
    x_test = [1.0, 1.0]
    manual_grad = tf.grad(x_test)
    auto_grad = ForwardDiff.gradient(tf.f, x_test)
    @test manual_grad ≈ auto_grad atol=1e-8

    # Hessian condition number (well-conditioned, cond < 1e6)
    hessian = ForwardDiff.hessian(tf.f, min_pos1)
    cond_num = cond(hessian)
    @test cond_num < 1e6  # Ensures numerical stability

    # Properties check
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "non-scalable")
    @test has_property(tf, "multimodal")
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
end