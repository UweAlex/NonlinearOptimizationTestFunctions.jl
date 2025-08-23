# test/runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: August 21, 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random
using LinearAlgebra

# Helper function for numerical gradient via finite differences
function finite_difference_gradient(f, x; eps_val=eps(Float64))
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        fx = abs(f(x))
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
    println("Starting Filter and Properties Tests")
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 39
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 9 
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 47
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 4
    finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
    @test length(finite_at_inf_funcs) == 2  # dejongf5, shekel
    @test has_property(add_property(ROSENBROCK_FUNCTION, "bounded"), "bounded")
end

@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
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
    println("Starting Zygote Hessian Tests")
    for tf in [ROSENBROCK_FUNCTION, SPHERE_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION]
        x = tf.meta[:start](2)
        H = Zygote.hessian(tf.f, x)
        @test size(H) == (2, 2)
        @test all(isfinite, H)
    end
end

@testset "Gradient Comparison for Differentiable Functions" begin
    println("Starting Gradient Comparison Tests")
    Random.seed!(1234)
    differentiable_functions = filter_testfunctions(tf -> has_property(tf, "differentiable"))
    @test length(differentiable_functions) == 47
    for tf in differentiable_functions
        n = try
            length(tf.meta[:min_position](2))
        catch
            length(tf.meta[:min_position]())
        end
        lb = any(isinf, tf.meta[:lb](n)) ? fill(-100.0, n) : tf.meta[:lb](n)
        ub = any(isinf, tf.meta[:ub](n)) ? fill(100.0, n) : tf.meta[:ub](n)
        @testset "$(tf.meta[:name]) Gradient Tests" begin
            println("Testing function: $(tf.meta[:name])")
            min_pos = tf.meta[:min_position](n)
            atol = 1e-5  # Strenge Toleranz für alle Funktionen
            is_at_boundary = any(i -> min_pos[i] == lb[i] || min_pos[i] == ub[i], 1:n)
            if !is_at_boundary && tf.meta[:name] != "bukin6"
                grad_at_min = tf.grad(min_pos)
                grad_norm = norm(grad_at_min)
                if grad_norm > 1e-6
                    println("Gradient at min_pos for $(tf.meta[:name]): $grad_at_min, min_pos=$min_pos, norm=$grad_norm")
					println("Function value at min_pos: $(tf.f(min_pos))")
                    println("ForwardDiff gradient at min_pos: ", ForwardDiff.gradient(tf.f, min_pos))
                    # Nachoptimierung, um Gradientenbetrag zu minimieren
                    try
                        function gradient_norm_squared(x)
                            grad = tf.grad(x)
                            if any(isnan, grad) || any(isinf, grad)
                                println("Warning: Invalid gradient in gradient_norm_squared at x=$x: $grad")
                                return Inf
                            end
                            return dot(grad, grad)
                        end
                        grad_norm_squared! = (G, x) -> begin
                            try
                                copyto!(G, ForwardDiff.gradient(gradient_norm_squared, x))
                            catch e
                                println("Error in ForwardDiff.gradient for $(tf.meta[:name]) at x=$x: $e")
                                fill!(G, NaN)
                            end
                        end
                        println("Starting Nachoptimierung for $(tf.meta[:name]) at min_pos=$min_pos")
                        result = optimize(gradient_norm_squared, grad_norm_squared!, lb, ub, min_pos, Fminbox(LBFGS()),
                                         Optim.Options(f_reltol=1e-12, g_tol=1e-12, iterations=1000))
                        new_minimizer = Optim.minimizer(result)
                        new_min_value = tf.f(new_minimizer)
                        new_grad = tf.grad(new_minimizer)
                        new_grad_norm = norm(new_grad)
                        println("Nachoptimierung für $(tf.meta[:name]):")
                        println("Neuer Minimizer: $new_minimizer")
                        println("Funktionswert: $new_min_value")
                        println("Neuer Gradient: $new_grad")
                        println("Neue Gradientennorm: $new_grad_norm")
                    catch e
                        println("Error in Nachoptimierung for $(tf.meta[:name]): $e")
                    end
                end
               @test grad_at_min ≈ zeros(n) atol=atol
            end
            for _ in 1:20
                x = lb + (ub - lb) .* rand(n)
                programmed_grad = tf.grad(x)
                numerical_grad = finite_difference_gradient(tf.f, x)
                ad_grad = ForwardDiff.gradient(tf.f, x)
                if !isapprox_scaled(programmed_grad, numerical_grad, atol=1e-3, rtol=1e-6)
                    println("Mismatch at x=$x for $(tf.meta[:name]):")
                    println("Programmed grad: ", programmed_grad)
                    println("Numerical grad: ", numerical_grad)
                    println("ForwardDiff grad: ", ad_grad)
                end
                @test isapprox_scaled(programmed_grad, numerical_grad, atol=1e-3, rtol=1e-6)
                @test isapprox_scaled(programmed_grad, ad_grad, atol=1e-3, rtol=1e-6)
            end
        end
    end
end

include("include_testfiles.jl")