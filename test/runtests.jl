# runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: November 12, 2025

using Test
using ForwardDiff
using Optim
using Zygote
using LinearAlgebra  # For norm() function
using NonlinearOptimizationTestFunctions

@testset "Minimum Validation" begin
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = get(tf.meta, :name, "unknown")
            is_scalable = has_property(tf, "scalable")
            n = nothing
            if is_scalable
                if haskey(tf.meta, :default_n)
                    n_candidate = tf.meta[:default_n]
                    try
                        pos = tf.meta[:min_position](n_candidate)
                        n = length(pos)
                    catch
                        n = nothing
                    end
                end
                if isnothing(n)
                    for candidate_n in [2, 4, 10]
                        try
                            pos = tf.meta[:min_position](candidate_n)
                            n = length(pos)
                            break
                        catch
                            continue
                        end
                    end
                end
            else
                try
                    pos = tf.meta[:min_position]()
                    n = length(pos)
                catch
                    n = 2
                end
            end

            if isnothing(n) || n <= 0
                @warn "Could not determine valid n for $name, skipping"
                continue
            end

            min_pos = is_scalable ? tf.meta[:min_position](n) : tf.meta[:min_position]()
            min_value = is_scalable ? tf.meta[:min_value](n) : tf.meta[:min_value]()
            f_val = tf.f(min_pos)

            if "has_noise" in tf.meta[:properties]
                if !(f_val >= min_value && f_val < min_value + 1.0)
                    @warn "Noisy minimum validation failed for $name: f_val=$f_val, expected range [$min_value, $(min_value + 1.0)]"
                    push!(failed_functions, name)
                end
                @test (f_val >= min_value && f_val < min_value + 1.0)
            else
                if abs(f_val - min_value) > 1e-6
                    @warn "Minimum validation failed for $name: f_val=$f_val, expected $min_value (deviation=$(abs(f_val - min_value)))"
                    push!(failed_functions, name)
                end
                @test isapprox(f_val, min_value; atol=1.0e-6)
            end
        catch err
            name = get(tf.meta, :name, "unknown")
            @error "Exception in Minimum Validation for $name" exception=(err, catch_backtrace())
            @test false
        end
    end
    if !isempty(failed_functions)
        @warn "Minimum Validation Summary: Failed for functions: $(join(failed_functions, ", "))"
    else
        println("Minimum Validation: All passed.")
    end
end

@testset "Edge Cases" begin
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = get(tf.meta, :name, "unknown")
            is_scalable = has_property(tf, "scalable")
            n = if is_scalable
                try
                    if haskey(tf.meta, :default_n)
                        length(tf.meta[:min_position](tf.meta[:default_n]))
                    else
                        length(tf.meta[:min_position](2))
                    end
                catch
                    length(tf.meta[:min_position](4))
                end
            else
                try
                    length(tf.meta[:min_position]())
                catch
                    2
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
        catch err
            name = get(tf.meta, :name, "unknown")
            @error "Error in Edge Cases for $name" exception=(err, catch_backtrace())
            push!(failed_functions, name)
            rethrow(err)
        end
    end
    if !isempty(failed_functions)
        @warn "Edge Cases Summary: Failed for functions: $(join(failed_functions, ", "))"
    else
        println("Edge Cases: All passed.")
    end
end

@testset "Zygote Hessian" begin
    failed_functions = String[]
    for tf in [ROSENBROCK_FUNCTION, SPHERE_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION]
        try
            name = get(tf.meta, :name, "unknown")
            if "has_noise" in tf.meta[:properties]
                continue
            end
            x = tf.meta[:start](2)
            H = Zygote.hessian(tf.f, x)
            @test size(H) == (2, 2)
            @test all(isfinite, H)
        catch err
            name = get(tf.meta, :name, "unknown")
            @error "Error in Zygote Hessian for $name" exception=(err, catch_backtrace())
            push!(failed_functions, name)
            rethrow(err)
        end
    end
    if !isempty(failed_functions)
        @warn "Zygote Hessian Summary: Failed for functions: $(join(failed_functions, ", "))"
    else
        println("Zygote Hessian: All passed.")
    end
end

@testset "Start Point Tests" begin
    for tf in values(TEST_FUNCTIONS)
        name = get(tf.meta, :name, "unknown")
        if !("bounded" in tf.meta[:properties])
            continue
        end
        if !("differentiable" in tf.meta[:properties])
            continue
        end

        is_scalable = has_property(tf, "scalable")
        n = if is_scalable
            haskey(tf.meta, :default_n) ? tf.meta[:default_n] : 2
        else
            try
                length(tf.meta[:min_position]())
            catch
                2
            end
        end

        x = is_scalable ? tf.meta[:start](n) : tf.meta[:start]()
        min_pos = is_scalable ? tf.meta[:min_position](n) : tf.meta[:min_position]()

        if all(isapprox.(x, min_pos, atol=1e-12))
            @error "Start point IS the global minimum for $name"
            @test false
        end
    end
end

include("gradient_accuracy_tests.jl")
include("minima_tests.jl")
include("include_testfiles.jl")