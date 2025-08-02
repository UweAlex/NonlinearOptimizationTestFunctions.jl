# test/runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: 19 July 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random

# Helper function for numerical gradient via finite differences
function finite_difference_gradient(f, x, h=1e-6)
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        x_plus = copy(x)
        x_minus = copy(x)
        x_plus[i] += h
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2h)
    end
    return grad
end



@testset "NonlinearOptimizationTestFunctions Cross-Function Tests" begin
 @testset "Filter and Properties Tests" begin
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 12 
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 2
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 16
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
    @test length(differentiable_functions) == 16
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
            atol = (tf.meta[:name] in ["langermann", "shekel"]) ? 0.3 : 0.001  # Shekel mit atol=0.3 hinzugefügt
            @test tf.grad(min_pos) ≈ zeros(n) atol=atol
            for _ in 1:20
                x = lb + (ub - lb) .* rand(n)
                programmed_grad = tf.grad(x)
                numerical_grad = finite_difference_gradient(tf.f, x)
                ad_grad = ForwardDiff.gradient(tf.f, x)
                @test programmed_grad ≈ numerical_grad atol=1e-3
                @test programmed_grad ≈ ad_grad atol=1e-3
            end
        end
    end
end
 
end

include("include_testfiles.jl")  
