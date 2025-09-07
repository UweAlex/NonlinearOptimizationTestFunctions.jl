# runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: September 06, 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random
using LinearAlgebra

@testset "Filter and Properties Tests" begin
    println("Starting Filter and Properties Tests")
    @test length(filter_testfunctions(tf -> has_property(tf, "bounded"))) == 62
    @test length(filter_testfunctions(tf -> has_property(tf, "continuous"))) == 60
    @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 46
    @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 10
    @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 53
    @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 1  # De Jong F4
    @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 12
    finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
    @test length(finite_at_inf_funcs) == 3  # dejongf5, shekel
end #testset

@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
    for tf in values(TEST_FUNCTIONS)
        is_scalable = "scalable" in tf.meta[:properties]
        n = if is_scalable
            try
                length(tf.meta[:min_position](2))
            catch
                length(tf.meta[:min_position](4))  # Fallback für skalierbare Funktionen
            end #try
        else
            try
                length(tf.meta[:min_position]())  # Für nicht-skalierbare Funktionen
            catch
                2  # Fallback für SixHumpCamelBack (n=2)
            end #try
        end #if
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
        end #if
        @test isfinite(tf.f(fill(1e-308, n)))
    end #for
end #testset

@testset "Zygote Hessian" begin
    println("Starting Zygote Hessian Tests")
    for tf in [ROSENBROCK_FUNCTION, SPHERE_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION]
        x = tf.meta[:start](2)
        H = Zygote.hessian(tf.f, x)
        @test size(H) == (2, 2)
        @test all(isfinite, H)
    end #for
end #testset

@testset "Start Point Tests" begin
    println("Starting Start Point Tests")
    for tf in values(TEST_FUNCTIONS)
        try
            if !("bounded" in tf.meta[:properties])
                continue  # Überspringe Funktionen ohne "bounded"-Eigenschaft
            end #if
            n = get_n(tf)
            x = n <= 0 ? tf.meta[:start](2) : tf.meta[:start]()
            lb = n <= 0 ? tf.meta[:lb](2) : tf.meta[:lb]()
            ub = n <= 0 ? tf.meta[:ub](2) : tf.meta[:ub]()
            bounds_violated = !all(x .>= lb) || !all(x .<= ub)
            if bounds_violated
                println("Bounds test failed for function: $(tf.meta[:name]), x=$x, lb=$lb, ub=$ub")  # Debugging
            end #if
            @test !bounds_violated  # Prüfe Grenzen
        catch e
            if e isa KeyError || e isa ArgumentError
                continue  # Überspringe Funktionen ohne :properties, :start, :min_position, :lb oder :ub
            else
                rethrow(e)  # Andere Fehler weiterwerfen
            end #if
        end #try
    end #for
end #testset

# Gradient Tests auslagern
include("gradient_accuracy_tests.jl")
include("minima_tests.jl")
include("include_testfiles.jl")