# runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: September 02, 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random
using LinearAlgebra

@testset "Filter and Properties Tests" begin
    println("Starting Filter and Properties Tests")
    @test length(filter_testfunctions(tf -> has_property(tf, "bounded"))) == 59
    @test length(filter_testfunctions(tf -> has_property(tf, "continuous"))) == 58
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 43
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 10
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 51
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 11
    finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
    @test length(finite_at_inf_funcs) == 3  # dejongf5, shekel
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

# Gradient Tests auslagern
  include("gradient_accuracy_tests.jl")
    include("minima_tests.jl")


include("include_testfiles.jl")