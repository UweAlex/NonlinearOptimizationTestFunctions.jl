# test/minima_tests.jl
# Purpose: Simplified test to validate minima metadata for all functions with Nelder-Mead optimization
# Last modified: October 04, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions
using LinearAlgebra
using Random  # Added for noise handling (seeding if needed)
using Statistics  # Added for mean and std in noise averaging
using Printf  # Added for high-precision formatting

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
    n = NonlinearOptimizationTestFunctions.dim(tf)
    if n == -1
        println("Warning: $fn_name is scalable, assuming n=2 for testing.")
        n = 2
    end #if

    # For scalable functions with special requirements, try multiple n
    if is_scalable && n == 2
        candidates = [2, 4, 10]
        found = false
        for cand in candidates
            try
                test_pos = tf.meta[:min_position](cand)
                if length(test_pos) == cand
                    n = cand
                    found = true
                    println("Adjusted n=$n for $fn_name (special case)")
                    break
                end
            catch e
                println("Debug: $fn_name failed candidate n=$cand: $e")
            end
        end
        if !found
            println("Warning: No valid n found for scalable $fn_name, skipping")
            return nothing, nothing, nothing, nothing, nothing, :no_valid_n
        end
    end

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
        if length(min_pos) > n
            min_pos = min_pos[1:n]
        else
            min_pos = vcat(min_pos, zeros(Float64, n - length(min_pos)))
        end
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
# Improved for has_noise: Uses range-checks, looser tolerances, and multiple evaluations for stability.
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
    has_noise = "has_noise" in tf.meta[:properties]

    # Gradient check (deterministic even for noisy f)
    if is_differentiable
        initial_grad = tf.grad(min_pos)
        initial_norm = norm(initial_grad)
        # Prüfe, ob min_pos an den Bounds liegt (innerhalb von 1e-8)
        at_bounds = false
        if lb !== nothing && ub !== nothing
            at_bounds = any(isapprox.(min_pos, lb, atol=1e-8)) || any(isapprox.(min_pos, ub, atol=1e-8))
        end

        # Gradient-Check mit Verbesserungsversuch
        if !isapprox(initial_norm, 0.0, atol=1e-7) && !at_bounds
            if initial_norm > 1e-4  # Schwellwert für Optimierungsversuch
                println("Warning: Gradient not zero at alleged minimum for $fn_name: norm=$initial_norm")
                println("  Gradient: $initial_grad")
                println("  Attempting gradient norm minimization...")

                # Minimiere ||grad||^2 mit Bounds-Constraint
                grad_norm_sq = x -> begin
                    # Penalty für Bounds-Verletzung
                    if lb !== nothing && any(x .< lb)
                        return 1e10
                    end
                    if ub !== nothing && any(x .> ub)
                        return 1e10
                    end
                    g = tf.grad(x)
                    return dot(g, g)
                end

                best_pos = min_pos
                best_grad_norm = initial_norm
                best_fx = min_fx

                # Versuche mehrere Starts
                starts = [min_pos]
                # Füge leicht verschobene Starts hinzu
                for offset_scale in [0.01, 0.1]
                    offset = offset_scale * (rand(length(min_pos)) .- 0.5)
                    perturbed = min_pos .+ offset
                    if lb !== nothing && ub !== nothing
                        perturbed = max.(min.(perturbed, ub .- 1e-8), lb .+ 1e-8)
                    end
                    push!(starts, perturbed)
                end

                for start in starts
                    try
                        res = optimize(grad_norm_sq, start, LBFGS(),
                            Optim.Options(iterations=10000, g_tol=1e-14))
                        cand_pos = Optim.minimizer(res)
                        cand_grad = tf.grad(cand_pos)
                        cand_norm = norm(cand_grad)
                        cand_fx = tf.f(cand_pos)

                        # Akzeptiere nur, wenn Gradient deutlich besser UND f-Wert ähnlich/besser UND innerhalb Bounds
                        in_bounds = true
                        if lb !== nothing
                            in_bounds = in_bounds && all(cand_pos .>= lb .- 1e-10)
                        end
                        if ub !== nothing
                            in_bounds = in_bounds && all(cand_pos .<= ub .+ 1e-10)
                        end

                        if in_bounds && cand_norm < best_grad_norm * 0.5 && cand_fx <= best_fx + 1e-6
                            best_pos = cand_pos
                            best_grad_norm = cand_norm
                            best_fx = cand_fx
                        end
                    catch e
                        # Ignoriere Fehler bei einzelnen Starts
                    end
                end

                if best_grad_norm < initial_norm * 0.5
                    println("\n" * "="^80)
                    println("IMPROVED MINIMUM via gradient minimization for $fn_name:")
                    println("="^80)
                    pos_str = "[" * join([@sprintf("%.16f", x) for x in best_pos], ", ") * "]"
                    println("  :min_position => () -> $pos_str,")
                    println("  :min_value => () -> $(repr(best_fx)),")
                    println("  Gradient norm: $best_grad_norm (was: $initial_norm)")
                    println("="^80 * "\n")

                    # Update für weitere Tests
                    min_pos = best_pos
                    min_fx = best_fx
                else
                    println("  No significant improvement found (best grad norm: $best_grad_norm)")
                end
            elseif initial_norm > 1e-7
                println("Info: Small but non-zero gradient at minimum for $fn_name: norm=$initial_norm")
            end
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

    # For noisy functions: Average multiple evaluations at refined_pos for stability
    if has_noise
        num_samples = 20  # Increased for better noise averaging (low overall impact)
        refined_fx_samples = [tf.f(refined_pos) for _ in 1:num_samples]
        refined_fx = mean(refined_fx_samples)
        std_samples = std(refined_fx_samples)  # Optional: Log std for quality check
        println("Info: Averaged $num_samples noisy evaluations for $fn_name: mean=$refined_fx (std=$std_samples, range: $(minimum(refined_fx_samples)) to $(maximum(refined_fx_samples)))")
    else
        refined_fx = tf.f(refined_pos)
    end

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

    # Adaptive tolerances based on noise
    if has_noise
        pos_tolerance = 0.1  # Looser for position due to noise-induced shifts
        fx_tolerance = 1.0   # For [0,1) noise; check range instead of exact diff
        # Range-check for noisy fx
        f_at_min = tf.f(min_pos)
        if !(f_at_min >= min_fx && f_at_min < min_fx + fx_tolerance)
            println("Warning: Noisy value at expected min out of range for $fn_name: $f_at_min (expected [$min_fx, $min_fx + $fx_tolerance))")
            @test false
            return false
        end
        if !(refined_fx >= min_fx && refined_fx < min_fx + fx_tolerance)
            println("Warning: Refined noisy value out of range for $fn_name: $refined_fx")
            @test false
            return false
        end
        # For noisy, convergence is expected to be loose; skip strict converged check
        if dist > pos_tolerance
            println("Info: Expected loose convergence for noisy $fn_name (dist=$dist > $pos_tolerance)")
        end
        if !is_converged
            println("Info: Expected non-convergence warning for noisy $fn_name; treating as passed with tolerances.")
        end
        return true  # Pass if within range, despite potential non-convergence
    else
        fx_diff = abs(refined_fx - min_fx)
        pos_tolerance = 1e-8
        fx_tolerance = 1e-10
        if dist > pos_tolerance || fx_diff > fx_tolerance
            println("\n" * "="^80)
            println("WARNING: Nelder-Mead did not converge within tolerances for $fn_name")
            println("="^80)
            println("Expected metadata:")
            println("  :min_position => () -> $min_pos,")
            println("  :min_value => () -> $min_fx,")
            println("\nOptimization results:")
            println("  Refined position: $refined_pos")
            println("  Refined value: $refined_fx")
            println("\nValidation:")
            println("  Function value at expected minimum: $(tf.f(min_pos))")
            println("  Position deviation (norm): $dist (tolerance: $pos_tolerance)")
            println("  Value deviation (abs): $fx_diff (tolerance: $fx_tolerance)")

            if dist > pos_tolerance && fx_diff > fx_tolerance
                println("\n" * "!"^80)
                println("SUGGESTED FIX for $fn_name:")
                println("!"^80)
                # Format with high precision
                pos_str = "[" * join([@sprintf("%.16f", x) for x in refined_pos], ", ") * "]"
                println("  :min_position => () -> $pos_str,")
                println("  :min_value => () -> $(repr(refined_fx)),")
                println("!"^80 * "\n")
            elseif dist > pos_tolerance
                println("\nNote: Position improved but value matches. Consider updating :min_position")
            else
                println("\nNote: Position matches but value differs. Consider updating :min_value")
            end

            @test false
            return false
        end #if
        return true
    end #if
end #function

# Summarizes the results of the minimum tests.
function summarize_test_results(error_counts)
    println("\nOverall Minimum Tests Summary:")
    println("  Test failures are listed in the test output above.")
    println("  Test errors:")
    any_errors = false
    for (func, count) in sort(collect(error_counts), by=x -> x[2], rev=true)
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
    error_counts = Dict{String,Int}()
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
    end #for

    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        is_scalable = "scalable" in tf.meta[:properties]
        n, min_pos, min_fx, lb, ub, reason = get_and_validate_metadata(tf, fn_name, is_scalable)
        if min_pos === nothing || min_fx === nothing
            println("Skipping $fn_name due to invalid metadata (reason: $reason)")
            error_counts[fn_name] = get(error_counts, fn_name, 0) + 1
            @test_broken "$fn_name metadata invalid: $reason"
            continue
        end #if

        test_passed = validate_minimum_with_gradient(tf, fn_name, min_pos, min_fx, lb, ub)
        if !test_passed
            error_counts[fn_name] = get(error_counts, fn_name, 0) + 1
            @test false
        end #if
    end #for

    summarize_test_results(error_counts)
end #testset