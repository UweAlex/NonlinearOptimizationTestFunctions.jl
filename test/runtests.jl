# test/runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: 11 August 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random

# Helper function for numerical gradient via finite differences
function finite_difference_gradient(f, x; h=1e-6)
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        x_plus = copy(x)
        x_minus = copy(x)
        x_plus[i] += h
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2*h)
    end
    return grad
end

@testset "Filter and Properties Tests" begin
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 26
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 7  
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 32
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 4  # Bukin6, De Jong F3, De Jong F4, und eine weitere
    @test has_property(add_property(ROSENBROCK_FUNCTION, "bounded"), "bounded")
end

@testset "Edge Cases" begin
    for tf in values(TEST_FUNCTIONS)
        n = try
            length(tf.meta[:min_position](2))
        catch
            length(tf.meta[:min_position]())
        end
        @test_throws ArgumentError tf.f(Float64[])
        @test isnan(tf.f(fill(NaN, n)))
        @test isinf(tf.f(fill(Inf, n)))
        @test isfinite(tf.f(fill(1e-308, n)))
    end
end

@testset "Zygote Hessian" begin
    for tf in [ROSENBROCK_FUNCTION, SPHERE_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION]
        x = tf.meta[:start](2)
        H = Zygote.hessian(tf.f, x)
        @test size(H) == (2, 2)
        @test all(isfinite, H)
    end
end

@testset "Gradient Comparison for Differentiable Functions" begin
    Random.seed!(1234)
    differentiable_functions = filter_testfunctions(tf -> has_property(tf, "differentiable"))
    @test length(differentiable_functions) == 32
    for tf in differentiable_functions
        n = try
            length(tf.meta[:min_position](2))
        catch
            length(tf.meta[:min_position]())
        end
        lb = any(isinf, tf.meta[:lb](n)) ? fill(-100.0, n) : tf.meta[:lb](n)
        ub = any(isinf, tf.meta[:ub](n)) ? fill(100.0, n) : tf.meta[:ub](n)
        @testset "$(tf.meta[:name]) Gradient Tests" begin
            min_pos = tf.meta[:min_position](n)
            atol = (tf.meta[:name] in ["langermann", "shekel", "dropwave"]) ? 0.3 : 0.001
            is_at_boundary = any(i -> min_pos[i] == lb[i] || min_pos[i] == ub[i], 1:n)
            if !is_at_boundary && tf.meta[:name] != "bukin6"
                @test tf.grad(min_pos) ≈ zeros(n) atol=atol
            end
            for _ in 1:20
                x = lb + (ub - lb) .* rand(n)
                programmed_grad = tf.grad(x)
                numerical_grad = finite_difference_gradient(tf.f, x)
                ad_grad = ForwardDiff.gradient(tf.f, x)
                @test programmed_grad ≈ numerical_grad atol=atol
                @test programmed_grad ≈ ad_grad atol=atol
            end
        end
    end
end

include("include_testfiles.jl")