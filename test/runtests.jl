# test/runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: 17 August 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random

# Helper function for numerical gradient via finite differences
function finite_difference_gradient(f, x; eps_val=eps(Float64))
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        fx = abs(f(x))
        # Adaptive Schrittweite basierend auf f(x) und x[i]
        h = fx > 0 ? sqrt(eps_val) * sqrt(fx) : 1e-8
        h = max(h, eps_val * abs(x[i]))
        x_plus = copy(x)
        x_minus = copy(x)
        x_plus[i] += h
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2*h)
        if !isfinite(grad[i])
            println("Non-finite gradient at i=$i, x=$x, h=$h, fx_plus=$(f(x_plus)), fx_minus=$(f(x_minus))")
        end
    end
    return grad
end

# Skalierte Vergleichsfunktion
function isapprox_scaled(a, b; atol=1e-3, rtol=1e-6)
    return all(abs.(a - b) .<= max.(atol, rtol * max.(abs.(a), abs.(b))))
end

@testset "Filter and Properties Tests" begin
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 37
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 9 
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 45
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 4  # Bukin6, De Jong F3, De Jong F4, und eine weitere
    finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
    @test length(finite_at_inf_funcs) == 2  # dejongf5, shekel
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
        if "bounded" in tf.meta[:properties]
            lb = tf.meta[:lb](n)
            ub = tf.meta[:ub](n)
            @test isfinite(tf.f(lb))
            @test isfinite(tf.f(ub))
        elseif "finite_at_inf" in tf.meta[:properties]
            @test isfinite(tf.f(fill(Inf, n)))
        else
            @test isinf(tf.f(fill(Inf, n)))
        end
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
    @test length(differentiable_functions) == 45
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
            atol = (tf.meta[:name] in ["langermann", "shekel", "dropwave", "deckkersaarts"]) ? 0.1 : 0.001
            is_at_boundary = any(i -> min_pos[i] == lb[i] || min_pos[i] == ub[i], 1:n)
            if !is_at_boundary && tf.meta[:name] != "bukin6"
                grad_at_min = tf.grad(min_pos)
                if !isapprox(grad_at_min, zeros(n), atol=atol)
                    println("Gradient at min_pos for $(tf.meta[:name]): $grad_at_min, min_pos=$min_pos")
                    println("ForwardDiff gradient at min_pos: ", ForwardDiff.gradient(tf.f, min_pos))
                end
                @test grad_at_min ≈ zeros(n) atol=atol
            end
            for _ in 1:20
                x = lb + (ub - lb) .* rand(n)
                programmed_grad = tf.grad(x)
                numerical_grad = finite_difference_gradient(tf.f, x)
                ad_grad = ForwardDiff.gradient(tf.f, x)
                if !isapprox_scaled(programmed_grad, numerical_grad, atol=atol, rtol=1e-6)
                    println("Mismatch at x=$x for $(tf.meta[:name]):")
                    println("Programmed grad: ", programmed_grad)
                    println("Numerical grad: ", numerical_grad)
                    println("ForwardDiff grad: ", ad_grad)
                end
                @test isapprox_scaled(programmed_grad, numerical_grad, atol=atol, rtol=1e-6)
                @test isapprox_scaled(programmed_grad, ad_grad, atol=atol, rtol=1e-6)
            end
        end
    end
end

include("include_testfiles.jl")