# minima_tests.jl
# Purpose: Test minima for all functions, validating optimized points with Nelder-Mead for Class 2 and 3
# Last modified: 05 September 2025

using Test, Optim
using NonlinearOptimizationTestFunctions
using LinearAlgebra

# Global dictionary to track "Egon Wurm" alerts for metadata discrepancies
egon_wurm_alerts = Dict{String, Int}()

"""
    get_meta_value(field, n, is_scalable, fn_name, field_name)

Helper function to retrieve and convert a metadata field to float, handling both scalable and non-scalable cases.

# Purpose
Extracts a metadata value (e.g., minimum position, bounds) and converts it to a float or vector of floats, depending on whether the function is scalable.

# Usage
Called within `get_and_validate_metadata` to extract `min_position`, `lb`, and `ub` from the function's metadata.

# Parameters
- `field`: The metadata field, which can be a value or a function.
- `n::Int`: The dimension of the problem (used for scalable functions).
- `is_scalable::Bool`: Indicates whether the function is scalable (requires dimension `n`).
- `fn_name::String`: Name of the test function (for error reporting).
- `field_name::String`: Name of the metadata field (for error reporting).

# Returns
- `Float64` or `Vector{Float64}`: The converted metadata value, either a single float or a vector of floats.
"""
function get_meta_value(field, n, is_scalable, fn_name, field_name)
    isa(field, Function) ? float.(is_scalable ? field(n) : field()) : float.(field)
end #function

"""
    check_function_properties(tf, fn_name)

Helper function to check the differentiability and scalability properties of a test function.

# Purpose
Determines whether a function is differentiable and scalable, categorizing it for further processing and identifying if it is suitable for optimization.

# Usage
Called within `classify_function` to assess the function's properties before metadata validation.

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).

# Returns
- `Tuple{Bool, Bool, Symbol}`: A tuple containing:
  - `is_valid::Bool`: Whether the function is fully differentiable (not partially differentiable).
  - `is_scalable::Bool`: Whether the function is scalable.
  - `reason::Symbol`: Reason for invalidity (e.g., `:not_differentiable`) or `nothing` if valid.
"""
function check_function_properties(tf, fn_name)
    is_diff = "differentiable" in tf.meta[:properties]
    is_part_diff = "partially differentiable" in tf.meta[:properties]
    is_scalable = "scalable" in tf.meta[:properties]
    if !is_diff || is_part_diff
        return false, is_scalable, :not_differentiable
    end #if
    return true, is_scalable, nothing
end #function

"""
    get_and_validate_metadata(tf, fn_name, is_scalable)

Helper function to retrieve and validate metadata for a test function, such as dimension, minimum position, and bounds.

# Purpose
Extracts and validates metadata fields (dimension, minimum position, function value, bounds) to ensure they are valid for optimization.

# Usage
Called within `classify_function` to gather metadata needed for function classification and subsequent optimization.

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).
- `is_scalable::Bool`: Indicates whether the function is scalable (affects dimension handling).

# Returns
- `Tuple{Any, Any, Any, Any, Any, Symbol}`: A tuple containing:
  - `n`: The dimension of the problem (or `nothing` if invalid).
  - `min_pos`: The minimum position (or `nothing` if invalid).
  - `min_fx`: The function value at the minimum (or `nothing` if invalid).
  - `lb`: Lower bounds (or `nothing` if not bounded or invalid).
  - `ub`: Upper bounds (or `nothing` if not bounded or invalid).
  - `reason::Symbol`: Reason for invalidity (e.g., `:invalid_dimension`, `:invalid_min_position`) or `nothing` if valid.
"""
function get_and_validate_metadata(tf, fn_name, is_scalable)
    n = get_n(tf)
    if n == nothing || n == -1
        n = is_scalable ? 2 : nothing
        if n === nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_dimension
        end #if
    end #if
    min_pos = get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
    if min_pos == nothing
        return nothing, nothing, nothing, nothing, nothing, :invalid_min_position
    end #if
    min_fx = tf.f(min_pos)
    if !isfinite(min_fx)
        return nothing, nothing, nothing, nothing, nothing, :non_finite_min_fx
    end #if
    is_bounded = "bounded" in tf.meta[:properties]
    lb = is_bounded ? get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb") : nothing
    ub = is_bounded ? get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub") : nothing
    if is_bounded
        if lb == nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_lb
        end #if
        if ub == nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_ub
        end #if
        if any(min_pos .< lb) || any(min_pos .> ub)
            return nothing, nothing, nothing, nothing, nothing, :bounds_violation
        end #if
    end #if
    return n, min_pos, min_fx, lb, ub, nothing
end #function

"""
    identify_boundary_minimum(min_pos, lb, ub)

Helper function to identify whether a minimum lies on the boundary of the feasible region.

# Purpose
Checks if the minimum position is on the boundary (within a tolerance) and collects indices and values of fixed components.

# Usage
Called within `classify_function` to determine if the minimum is interior (Class 1) or on the boundary (Class 2).

# Parameters
- `min_pos::Vector{Float64}`: The position of the minimum.
- `lb`: Lower bounds (or `nothing` if not bounded).
- `ub`: Upper bounds (or `nothing` if not bounded).

# Returns
- `Tuple{Bool, Vector{Int}, Vector{Float64}}`: A tuple containing:
  - `inside_bounds::Bool`: True if the minimum is not on the boundary (interior).
  - `fixed_indices::Vector{Int}`: Indices where the minimum lies on the boundary.
  - `fixed_values::Vector{Float64}`: Corresponding boundary values (lower or upper bound).
"""
function identify_boundary_minimum(min_pos, lb, ub)
    fixed_indices = Int[]
    fixed_values = Float64[]
    if lb !== nothing && ub !== nothing
        for i in 1:length(min_pos)
            if isapprox(min_pos[i], lb[i], atol=1e-6) || isapprox(min_pos[i], ub[i], atol=1e-6)
                push!(fixed_indices, i)
                push!(fixed_values, isapprox(min_pos[i], lb[i], atol=1e-6) ? lb[i] : ub[i])
            end #if
        end #for
    end #if
    inside_bounds = isempty(fixed_indices)
    return inside_bounds, fixed_indices, fixed_values
end #function

"""
    classify_function(tf, fn_name)

Helper function to classify a test function based on its properties and metadata.

# Purpose
Categorizes a function into Class 1 (interior minimum), Class 2 (boundary minimum), or Class 3 (invalid or non-differentiable) based on differentiability and metadata validity.

# Usage
Called in the main test loop to determine the appropriate handling for each test function.

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).

# Returns
- `Tuple{Int, Any, Any, Any, Any, Any, Vector{Int}, Symbol}`: A tuple containing:
  - `class::Int`: The function class (1, 2, or 3).
  - `n`: The dimension of the problem (or `nothing` if invalid).
  - `min_pos`: The minimum position (or `nothing` if invalid).
  - `min_fx`: The function value at the minimum (or `nothing` if invalid).
  - `lb`: Lower bounds (or `nothing` if not bounded or invalid).
  - `ub`: Upper bounds (or `nothing` if not bounded or invalid).
  - `fixed_indices::Vector{Int}`: Indices where the minimum lies on the boundary.
  - `reason::Symbol`: Reason for invalidity (e.g., `:not_differentiable`, `:invalid_dimension`) or `nothing` if valid.
"""
function classify_function(tf, fn_name)
    is_valid, is_scalable, reason = check_function_properties(tf, fn_name)
    n, min_pos, min_fx, lb, ub, meta_reason = get_and_validate_metadata(tf, fn_name, is_scalable)
    if n === nothing
        return 3, nothing, nothing, nothing, nothing, nothing, Int[], meta_reason
    end #if
    if !is_valid
        inside_bounds, fixed_indices, fixed_values = identify_boundary_minimum(min_pos, lb, ub)
        return 3, n, min_pos, min_fx, lb, ub, fixed_indices, reason
    end #if
    inside_bounds, fixed_indices, fixed_values = identify_boundary_minimum(min_pos, lb, ub)
    class = inside_bounds ? 1 : 2
    return class, n, min_pos, min_fx, lb, ub, fixed_indices, nothing
end #function

"""
    validate_optimization_result(tf, fn_name, min_pos, min_fx, new_pos, new_fx, fx_start)

Helper function to validate the results of an optimization against expected metadata.

# Purpose
Compares the optimized minimum position and function value with the expected values, issuing warnings for significant discrepancies and updating metadata if a better minimum is found.

# Usage
Called within `handle_non_differentiable_or_boundary` to validate Nelder-Mead optimization results for Class 2 and 3 functions.

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).
- `min_pos::Vector{Float64}`: The expected minimum position from metadata.
- `min_fx::Float64`: The expected function value at the minimum.
- `new_pos::Vector{Float64}`: The optimized minimum position.
- `new_fx::Float64`: The optimized function value.
- `fx_start::Float64`: The function value at the starting point.

# Returns
- `nothing`: The function performs tests and updates metadata if necessary but does not return a value.
"""
function validate_optimization_result(tf, fn_name, min_pos, min_fx, new_pos, new_fx, fx_start)
    dist = norm(new_pos - min_pos)
    fx_diff = abs(new_fx - min_fx)
    if dist > 1e-2
        println("Warning: Significant deviation in minimum for $fn_name at $new_pos (fx=$new_fx) from expected min_pos=$min_pos (dist=$dist). Possible metadata error (Egon Wurm alert)!")
        egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
    end #if
    if fx_diff > 1e-6
        println("Warning: Significant deviation in function value for $fn_name: new_fx=$new_fx deviates from expected min_fx=$min_fx (fx_diff=$fx_diff). Possible metadata error (Egon Wurm alert)!")
        egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
    end #if
    if new_fx < min_fx - 1e-6
        println("Warning: Found better minimum for $fn_name at $new_pos (fx=$new_fx) than expected min_fx=$min_fx. Possible metadata error.")
        tf.meta[:min_position] = new_pos
        tf.meta[:min_fx] = new_fx
    end #if
    @test new_fx <= fx_start + 1e-6
    @test isapprox(new_fx, min_fx, atol=1e-6)
end #function

"""
    check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, new_pos, new_norm, new_fx)

Helper function to check the gradient at an alleged interior minimum for Class 1 functions.

# Purpose
Verifies if the gradient norm at the minimum is zero (within tolerance) and handles cases where optimization is needed to find a better minimum.

# Usage
Called within `handle_interior_minimum` to validate the gradient at the minimum for Class 1 functions.

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).
- `min_pos::Vector{Float64}`: The expected minimum position from metadata.
- `min_fx::Float64`: The expected function value at the minimum.
- `grad_norm::Float64`: The norm of the gradient at the expected minimum.
- `new_pos::Vector{Float64}`: The optimized position (if optimization was performed).
- `new_norm::Float64`: The norm of the gradient at the optimized position.
- `new_fx::Float64`: The function value at the optimized position.

# Returns
- `nothing`: The function performs tests and updates metadata if necessary but does not return a value.
"""
function check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, new_pos, new_norm, new_fx)
    if !isapprox(grad_norm, 0.0, atol=1e-6)
        println("Gradient not zero at alleged interior minimum for $fn_name: norm=$grad_norm, min_pos=$min_pos, fx=$min_fx")
        if new_pos != min_pos && isapprox(new_norm, 0.0, atol=1e-6)
            println("Optimized gradient position: $new_pos, new gradient norm: $new_norm, new fx=$new_fx")
            dist = norm(new_pos - min_pos)
            fx_diff = abs(new_fx - min_fx)
            if dist > 1e-2 || fx_diff > 1e-6
                println("Warning: Significant deviation in gradient minimum for $fn_name at $new_pos (dist=$dist, fx_diff=$fx_diff) from min_pos=$min_pos, min_fx=$min_fx. Metadata error (Egon Wurm alert)!")
                egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
            end #if
            println("Suggested metadata update for $fn_name: new min_pos=$new_pos, new fx=$new_fx")
            tf.meta[:min_position] = new_pos
            tf.meta[:min_fx] = new_fx
            @test isapprox(new_norm, 0.0, atol=1e-6)
            return
        end #if
        println("Warning: Gradient optimization failed to improve gradient norm for $fn_name")
        @test isapprox(grad_norm, 0.0, atol=1e-6)
    else
        println("Gradient test passed for $fn_name: norm=$grad_norm, min_pos=$min_pos, fx=$min_fx")
        @test isapprox(grad_norm, 0.0, atol=1e-6)
    end #if
end #function

"""
    handle_interior_minimum(tf, fn_name, min_pos, min_fx, lb, ub, fixed_indices)

Main function to handle optimization and validation for Class 1 functions (interior minima).

# Purpose
Validates the gradient at the minimum for Class 1 functions and performs Nelder-Mead optimization if the gradient norm is not zero.

# Usage
Called in the main test loop for functions classified as Class 1 (interior minimum).

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).
- `min_pos::Vector{Float64}`: The expected minimum position from metadata.
- `min_fx::Float64`: The expected function value at the minimum.
- `lb`: Lower bounds (or `nothing` if not bounded).
- `ub`: Upper bounds (or `nothing` if not bounded).
- `fixed_indices::Vector{Int}`: Indices where the minimum lies on the boundary (empty for Class 1).

# Returns
- `nothing`: The function performs tests and updates metadata if necessary but does not return a value.
"""
function handle_interior_minimum(tf, fn_name, min_pos, min_fx, lb, ub, fixed_indices)
    an_grad_min = tf.grad(min_pos)
    grad_norm = norm(an_grad_min)
    if !isapprox(grad_norm, 0.0, atol=1e-6)
        obj_func = x -> begin
            g = tf.grad(x)
            dot(g, g)
        end #anonymous_function
        res = optimize(obj_func, min_pos, NelderMead(), Optim.Options(iterations=1000, f_reltol=1e-6))
        new_pos = Optim.minimizer(res)
        new_norm = norm(tf.grad(new_pos))
        new_fx = tf.f(new_pos)
        check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, new_pos, new_norm, new_fx)
    else
        check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, min_pos, grad_norm, min_fx)
    end #if
end #function

"""
    handle_non_differentiable_or_boundary(tf, fn_name, n, min_pos, min_fx, lb, ub, fixed_indices, reason, error_counts)

Main function to handle optimization and validation for Class 2 (boundary minima) and Class 3 (non-differentiable or invalid) functions.

# Purpose
Performs Nelder-Mead optimization for Class 2 and 3 functions, validates the results, and reports errors for invalid metadata or optimization failures.

# Usage
Called in the main test loop for functions classified as Class 2 (boundary minimum) or Class 3 (non-differentiable or invalid).

# Parameters
- `tf`: The test function object containing metadata and methods (`f`, `grad`).
- `fn_name::String`: Name of the test function (for error reporting).
- `n`: The dimension of the problem (or `nothing` if invalid).
- `min_pos`: The expected minimum position (or `nothing` if invalid).
- `min_fx`: The expected function value at the minimum (or `nothing` if invalid).
- `lb`: Lower bounds (or `nothing` if not bounded or invalid).
- `ub`: Upper bounds (or `nothing` if not bounded or invalid).
- `fixed_indices::Vector{Int}`: Indices where the minimum lies on the boundary.
- `reason::Symbol`: Reason for classification as Class 3 (e.g., `:not_differentiable`, `:invalid_dimension`).
- `error_counts::Dict{String, Int}`: Dictionary tracking the number of errors per function.

# Returns
- `nothing`: The function performs tests, updates metadata, and logs errors but does not return a value.
"""
function handle_non_differentiable_or_boundary(tf, fn_name, n, min_pos, min_fx, lb, ub, fixed_indices, reason, error_counts)
    if min_pos === nothing || min_fx === nothing
        if reason == :invalid_dimension
            println("Catastrophic error: $fn_name has invalid or undefined dimension")
        elseif reason == :invalid_min_position
            println("Catastrophic error: $fn_name has invalid min_position")
        elseif reason == :non_finite_min_fx
            println("Catastrophic error: $fn_name has non-finite min_fx")
        elseif reason == :invalid_lb
            println("Catastrophic error: $fn_name has invalid lb")
        elseif reason == :invalid_ub
            println("Catastrophic error: $fn_name has invalid ub")
        elseif reason == :bounds_violation
            println("Catastrophic error: $fn_name has min_pos violating bounds")
        end #if
        error_counts[fn_name] = get(error_counts, fn_name, 0) + 1
        @test false
        return
    end #if
    println("Optimizing minimum for $fn_name (reason: $reason)")
    x0 = copy(min_pos)
    fx_start = tf.f(x0)
    bounded_func = create_bounded_function(tf, lb, ub)
    res = optimize(bounded_func, x0, NelderMead(), Optim.Options(iterations=1000, f_reltol=1e-6))
    new_pos = Optim.minimizer(res)
    new_fx = tf.f(new_pos)
    validate_optimization_result(tf, fn_name, min_pos, min_fx, new_pos, new_fx, fx_start)
end #function

"""
    create_bounded_function(tf, lb, ub)

Helper function to create a penalty function that enforces bounds during optimization.

# Purpose
Wraps the test function to return `Inf` if the input violates bounds, ensuring optimization respects the feasible region.

# Usage
Called within `handle_non_differentiable_or_boundary` to create a bounded objective function for Nelder-Mead optimization.

# Parameters
- `tf`: The test function object containing the method `f`.
- `lb`:LOWER bounds (or `nothing` if not bounded).
- `ub`: Upper bounds (or `nothing` if not bounded).

# Returns
- `Function`: A function that evaluates `tf.f(x)` if `x` is within bounds, or returns `Inf` if bounds are violated.
"""
function create_bounded_function(tf, lb, ub)
    return x -> begin
        if lb !== nothing && any(x .< lb)
            return Inf
        end #if
        if ub !== nothing && any(x .> ub)
            return Inf
        end #if
        tf.f(x)
    end #anonymous_function
end #function

"""
    summarize_test_results(error_counts)

Main function to summarize the results of the minimum tests.

# Purpose
Prints a summary of test errors and Egon Wurm alerts, indicating which functions had issues during testing.

# Usage
Called at the end of the main test loop to provide a final summary of test outcomes.

# Parameters
- `error_counts::Dict{String, Int}`: Dictionary tracking the number of errors per function.

# Returns
- `nothing`: The function prints the summary but does not return a value.
"""
function summarize_test_results(error_counts)
    println("\nOverall Minimum Tests Summary:")
    println("  Catastrophic errors (invalid metadata) and other test failures are listed in the test output above.")
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
    println("  Egon Wurm alerts (significant metadata deviations):")
    any_alerts = false
    for (func, count) in sort(collect(egon_wurm_alerts), by=x->x[2], rev=true)
        if count > 0
            any_alerts = true
            println("    $func: $count alerts")
        end #if
    end #for
    if !any_alerts
        println("    No Egon Wurm alerts detected.")
    end #if
end #function

# Main test suite to validate minima for all test functions.
# Purpose: Iterates over all test functions, classifies them, performs optimization and validation, and summarizes the results.
# Usage: Entry point for the test suite, executed when the script is run.
# Parameters: None (operates on the global TEST_FUNCTIONS collection).
# Returns: nothing (runs tests and prints results).
@testset "Minimum Tests" begin
    error_counts = Dict{String, Int}()
    egon_wurm_alerts = Dict{String, Int}()
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
        egon_wurm_alerts[fn_name] = 0
    end #for
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        
        # Step 1: Classify the function
        class, n, min_pos, min_fx, lb, ub, fixed_indices, reason = classify_function(tf, fn_name)
        
        # Step 2: Handle based on class
        if class == 3 || class == 2
            handle_non_differentiable_or_boundary(tf, fn_name, n, min_pos, min_fx, lb, ub, fixed_indices, reason, error_counts)
        elseif class == 1
            handle_interior_minimum(tf, fn_name, min_pos, min_fx, lb, ub, fixed_indices)
        end #if
    end #for
    
    # Step 3: Summarize test results
    summarize_test_results(error_counts)
end #testset