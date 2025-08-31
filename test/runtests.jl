# test/runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: August 24, 2025

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
	@test length(filter_testfunctions(tf -> has_property(tf, "bounded"))) == 56
    @test length(filter_testfunctions(tf -> has_property(tf, "continuous"))) == 55
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 41
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 10
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 53
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 6
    finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
    @test length(finite_at_inf_funcs) == 3  # dejongf5, shekel
    @test has_property(add_property(ROSENBROCK_FUNCTION, "bounded"), "bounded")
end

@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
    for tf in values(TEST_FUNCTIONS)
        is_scalable = "scalable" in tf.meta[:properties]
        n = if is_scalable
            try
                length(tf.meta[:min_position](2))
            catch
                length(tf.meta[:min_position](4))  # Fallback für skalierbare Funktionen
            end
        else
            try
                length(tf.meta[:min_position]())  # Für nicht-skalierbare Funktionen
            catch
                2  # Fallback für SixHumpCamelBack (n=2)
            end
        end
        @test_throws ArgumentError tf.f(Float64[])
        @test isnan(tf.f(fill(NaN, n)))
        if "bounded" in tf.meta[:properties]
            lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
            ub = is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
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




@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
    for tf in values(TEST_FUNCTIONS)
        is_scalable = "scalable" in tf.meta[:properties]
        n = if is_scalable
            try
                length(tf.meta[:min_position](2))
            catch
                length(tf.meta[:min_position](4))  # Fallback für skalierbare Funktionen
            end
        else
            try
                length(tf.meta[:min_position]())  # Für nicht-skalierbare Funktionen
            catch
                2  # Fallback für Schaffer N.1 (n=2)
            end
        end
        @test_throws ArgumentError tf.f(Float64[])
        @test isnan(tf.f(fill(NaN, n)))
        if "bounded" in tf.meta[:properties]
            lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
            ub = is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
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



include("include_testfiles.jl")