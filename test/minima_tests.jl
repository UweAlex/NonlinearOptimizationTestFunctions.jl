# test/minima_tests.jl
# Purpose: Simplified test to validate minima metadata for all functions with Nelder-Mead optimization
# Last modified: September 13, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions
using LinearAlgebra

# Retrieves and validates basic metadata for a test function with detailed error reporting.
#
# Parameters:
# - `tf`: The test function object containing metadata.
# - `fn_name::String`: Name of the test function.
# - `is_scalable`: Boolean indicating if the function is scalable.
#
# Returns:
# - `n`: Dimension (determined using get_n).
# - `min_pos::Vector{Float64}`: Minimum position.
# - `min_fx::Float64`: Minimum function value.
# - `lb`: Lower bounds.
# - `ub`: Upper bounds.
# - `reason`: Symbol indicating validation failure (if any).
function get_and_validate_metadata(tf, fn_name, is_scalable)
    n = get_n(tf)
    if n == -1
        println("Warning: $fn_name is scalable, assuming n=2 for testing.")
        n = 2
    end #if
    min_pos = try
        is_scalable ? tf.meta[:min_position](n) : tf.meta[:min_position]()
    catch e
        println("Warning: $fn_name has invalid or missing min_position in metadata: $e")
        return nothing, nothing, nothing, nothing, nothing, :invalid_min_position
    end #try
    if !isa(min_pos, Vector)
        println("Warning: $fn_name min_position is not a Vector.")
        return nothing, nothing, nothing, nothing, nothing, :invalid_min_position
    end #if
    if length(min_pos) != n
        println("Warning: $fn_name min_position length ($(length(min_pos))) does not match dimension ($n), truncating or padding.")
        min_pos = min_pos[1:min(n, length(min_pos))]
    end #if
    min_fx = try
        is_scalable ? (isa(tf.meta[:min_value], Function) ? tf.meta[:min_value](n) : tf.meta[:min_value]) : tf.meta[:min_value]()
    catch e
        min_fx = tf.f(min_pos)
        println("Warning: $fn_name has no valid min_value, using computed value: $min_fx ($e)")
    end #try
    if !isfinite(min_fx)
        println("Warning: $fn_name has non-finite min_value: $min_fx")
        return nothing, nothing, nothing, nothing, nothing, :invalid_min_value
    end #if
    lb = try
        is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
    catch e
        println("Warning: $fn_name has invalid lower bounds: $e")
        nothing
    end #try
    ub = try
        is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
    catch e
        println("Warning: $fn_name has invalid upper bounds: $e")
        nothing
    end #try
    return n, float.(min_pos), float(min_fx), lb, ub, nothing
end #function

# Validates the minimum position by applying Nelder-Mead optimization and comparing with metadata.
#
# Purpose:
# For differentiable functions, checks if the gradient is zero to skip optimization. For all functions, optimizes with Nelder-Mead and validates metadata.
#
# Parameters:
# - `tf`: The test function object containing metadata and methods (`f`, `grad`).
# - `fn_name::String`: Name of the test function (for error reporting).
# - `min_pos::Vector{Float64}`: The expected minimum position from metadata.
# - `min_fx::Float64`: The expected function value at the minimum.
# - `lb`: Lower bounds (or `nothing` if not bounded).
# - `ub`: Upper bounds (or `nothing` if not bounded).
#
# Returns:
# - `Bool`: True if test passed, False if test failed.
function validate_minimum_with_gradient(tf, fn_name, min_pos, min_fx, lb, ub)
    is_differentiable = "differentiable" in tf.meta[:properties] && !("partially differentiable" in tf.meta[:properties])
    
    if is_differentiable
        initial_grad = tf.grad(min_pos)
        initial_norm = norm(initial_grad)
        # Prüfe, ob min_pos an den Bounds liegt (innerhalb von 1e-8)
        at_bounds = false
        if lb !== nothing && ub !== nothing
            at_bounds = any(isapprox.(min_pos, lb, atol=1e-8)) || any(isapprox.(min_pos, ub, atol=1e-8))
        end
        if !isapprox(initial_norm, 0.0, atol=1e-3) && !at_bounds
            println("Warning: Gradient not zero at alleged minimum for $fn_name: norm=$initial_norm")
        end #if
    end #if
    
    bounded_func = x -> begin
        if lb !== nothing && any(x .< lb)
            return Inf
        end #if
        if ub !== nothing && any(x .> ub)
            return Inf
        end #if
        tf.f(x)
    end #function
    iterations = 100000
    res_f = optimize(bounded_func, min_pos, NelderMead(), Optim.Options(iterations=iterations, f_reltol=1e-9))
    refined_pos = Optim.minimizer(res_f)
    refined_fx = tf.f(refined_pos)
    is_converged = try
        Optim.converged(res_f)
    catch
        try
            getproperty(res_f, :converged)
        catch e
            println("Error: Failed to check convergence for $fn_name: $e")
            return false
        end #try
    end #try
    
    dist = norm(refined_pos - min_pos)
    fx_diff = abs(refined_fx - min_fx)
    pos_tolerance = 1e-8
    fx_tolerance = 1e-10
    
    if dist > pos_tolerance || fx_diff > fx_tolerance
        println("Warning: Nelder-Mead did not converge within tolerances for $fn_name")
        @info "Nelder-Mead Nicht-Konvergenz Details für $fn_name" Erwartete_Minimum_Position=min_pos Erwarteter_Minimalwert=min_fx Gefundene_Position=refined_pos 
		print("refined_pos: ");println(refined_pos)
		Gefundener_Funktionswert=refined_fx
		print("refined_fx: ");println(refined_fx)
		print("Funktionswert am vorgeblichen minimum:");println(tf.f(min_pos));
	
        println("  Deviation: distance=$dist, fx_diff=$fx_diff")
        @test false
        return false
    end #if
    return true
end #function

# Summarizes the results of the minimum tests.
function summarize_test_results(error_counts)
    println("\nOverall Minimum Tests Summary:")
    println("  Test failures are listed in the test output above.")
    println("  Test errors:")
    any_errors = false
    for (func, count) in sort(collect(error_counts), by=x->x[2], rev=true)
        if count > 0
            any_errors = true
            println("    $func: $count errors")
        end #if
    end #for
    if !any_errors
        println("    No test errors detected.")
    end #if
end #function

# Main test suite
@testset "Minimum Tests" begin
    error_counts = Dict{String, Int}()
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
    end #for
    
    first_failure = true
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        is_scalable = "scalable" in tf.meta[:properties]
        n, min_pos, min_fx, lb, ub, reason = get_and_validate_metadata(tf, fn_name, is_scalable)
        if min_pos === nothing || min_fx === nothing
            println("Skipping $fn_name due to invalid metadata (reason: $reason)")
            error_counts[fn_name] = get(error_counts, fn_name, 0) + 1
            @test false
            if first_failure
                println("First failure detected at $fn_name, stopping tests.")
                break
            end #if
        else
            test_passed = validate_minimum_with_gradient(tf, fn_name, min_pos, min_fx, lb, ub)
            if !test_passed && first_failure
                println("First failure detected at $fn_name during validation, stopping tests.")
                break
            end #if
        end #if
        first_failure = false
    end #for
    
    summarize_test_results(error_counts)
end #testset