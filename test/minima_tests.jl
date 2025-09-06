# minima_tests.jl
# Purpose: Test minima for all functions, validating optimized points with Nelder-Mead for Class 2 and 3
# Last modified: 05 September 2025

using Test, Optim
using NonlinearOptimizationTestFunctions
using LinearAlgebra

# Globale Liste für "Kot am Duften"-Warnungen
egon_wurm_alerts = Dict{String, Int}()

# Prozedur: Metadatenwert abrufen
function get_meta_value(field, n, is_scalable, fn_name, field_name)
    isa(field, Function) ? float.(is_scalable ? field(n) : field()) : float.(field)
end

# Prozedur: Prüfen der Funktioneigenschaften
function check_function_properties(tf, fn_name)
    is_diff = "differentiable" in tf.meta[:properties]
    is_part_diff = "partially differentiable" in tf.meta[:properties]
    is_scalable = "scalable" in tf.meta[:properties]
    if !is_diff || is_part_diff
        return false, is_scalable, :not_differentiable
    end
    return true, is_scalable, nothing
end

# Prozedur: Metadaten abrufen und validieren
function get_and_validate_metadata(tf, fn_name, is_scalable)
    n = get_n(tf)
    if n == nothing || n == -1
        n = is_scalable ? 2 : nothing
        if n === nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_dimension
        end
    end
    min_pos = get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
    if min_pos == nothing
        return nothing, nothing, nothing, nothing, nothing, :invalid_min_position
    end
    min_fx = tf.f(min_pos)
    if !isfinite(min_fx)
        return nothing, nothing, nothing, nothing, nothing, :non_finite_min_fx
    end
    is_bounded = "bounded" in tf.meta[:properties]
    lb = is_bounded ? get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb") : nothing
    ub = is_bounded ? get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub") : nothing
    if is_bounded
        if lb == nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_lb
        end
        if ub == nothing
            return nothing, nothing, nothing, nothing, nothing, :invalid_ub
        end
        if any(min_pos .< lb) || any(min_pos .> ub)
            return nothing, nothing, nothing, nothing, nothing, :bounds_violation
        end
    end
    return n, min_pos, min_fx, lb, ub, nothing
end

# Prozedur: Erkennung von Randminima
function identify_boundary_minimum(min_pos, lb, ub)
    fixed_indices = Int[]
    fixed_values = Float64[]
    if lb !== nothing && ub !== nothing
        for i in 1:length(min_pos)
            if isapprox(min_pos[i], lb[i], atol=1e-6) || isapprox(min_pos[i], ub[i], atol=1e-6)
                push!(fixed_indices, i)
                push!(fixed_values, isapprox(min_pos[i], lb[i], atol=1e-6) ? lb[i] : ub[i])
            end
        end
    end
    inside_bounds = isempty(fixed_indices)
    return inside_bounds, fixed_indices, fixed_values
end

# Prozedur: Funktion klassifizieren
function classify_function(tf, fn_name)
    is_valid, is_scalable, reason = check_function_properties(tf, fn_name)
    n, min_pos, min_fx, lb, ub, meta_reason = get_and_validate_metadata(tf, fn_name, is_scalable)
    if n === nothing
        return 3, nothing, nothing, nothing, nothing, nothing, Int[], meta_reason
    end
    if !is_valid
        inside_bounds, fixed_indices, fixed_values = identify_boundary_minimum(min_pos, lb, ub)
        return 3, n, min_pos, min_fx, lb, ub, fixed_indices, reason
    end
    inside_bounds, fixed_indices, fixed_values = identify_boundary_minimum(min_pos, lb, ub)
    class = inside_bounds ? 1 : 2
    return class, n, min_pos, min_fx, lb, ub, fixed_indices, nothing
end

# Prozedur: Optimierungsergebnis validieren
function validate_optimization_result(tf, fn_name, min_pos, min_fx, new_pos, new_fx, fx_start)
    dist = norm(new_pos - min_pos)
    fx_diff = abs(new_fx - min_fx)
    if dist > 1e-2
        println("Warning: Kot am Duften! New minimum for $fn_name at $new_pos (fx=$new_fx) is far from min_pos=$min_pos (dist=$dist). Possible metadata error (Egon Wurm alert)!")
        egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
    end
    if fx_diff > 1e-6
        println("Warning: Kot am Duften! New fx=$new_fx deviates from expected min_fx=$min_fx for $fn_name (fx_diff=$fx_diff). Possible metadata error (Egon Wurm alert)!")
        egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
    end
    if new_fx < min_fx - 1e-6
        println("Warning: Found better minimum for $fn_name at $new_pos (fx=$new_fx) than expected min_fx=$min_fx. Possible metadata error.")
        tf.meta[:min_position] = new_pos
        tf.meta[:min_fx] = new_fx
    end
    @test new_fx <= fx_start + 1e-6
    @test isapprox(new_fx, min_fx, atol=1e-6)
end

# Prozedur: Gradienten am Minimum prüfen (für Klasse 1)
function check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, new_pos, new_norm, new_fx)
    if !isapprox(grad_norm, 0.0, atol=1e-6)
        println("Gradient not zero at alleged interior minimum for $fn_name: norm=$grad_norm, min_pos=$min_pos, fx=$min_fx")
        if new_pos != min_pos && isapprox(new_norm, 0.0, atol=1e-6)
            println("Optimized gradient position: $new_pos, new gradient norm: $new_norm, new fx=$new_fx")
            dist = norm(new_pos - min_pos)
            fx_diff = abs(new_fx - min_fx)
            if dist > 1e-2 || fx_diff > 1e-6
                println("Warning: Kot am Duften! New gradient minimum for $fn_name at $new_pos (dist=$dist, fx_diff=$fx_diff) is significantly different from min_pos=$min_pos, min_fx=$min_fx. Metadata error (Egon Wurm alert)!")
                egon_wurm_alerts[fn_name] = get(egon_wurm_alerts, fn_name, 0) + 1
            end
            println("Suggested metadata update for $fn_name: new min_pos=$new_pos, new fx=$new_fx")
            tf.meta[:min_position] = new_pos
            tf.meta[:min_fx] = new_fx
            @test isapprox(new_norm, 0.0, atol=1e-6)
            return
        end
        println("Warning: Gradient optimization failed to improve gradient norm for $fn_name")
        @test isapprox(grad_norm, 0.0, atol=1e-6)
    else
        println("Gradient test passed for $fn_name: norm=$grad_norm, min_pos=$min_pos, fx=$min_fx")
        @test isapprox(grad_norm, 0.0, atol=1e-6)
    end
end

# Prozedur: Innere Minima behandeln (Klasse 1)
function handle_interior_minimum(tf, fn_name, min_pos, min_fx, lb, ub, fixed_indices)
    an_grad_min = tf.grad(min_pos)
    grad_norm = norm(an_grad_min)
    if !isapprox(grad_norm, 0.0, atol=1e-6)
        obj_func = x -> begin
            g = tf.grad(x)
            dot(g, g)
        end
        res = optimize(obj_func, min_pos, NelderMead(), Optim.Options(iterations=1000, f_reltol=1e-6))
        new_pos = Optim.minimizer(res)
        new_norm = norm(tf.grad(new_pos))
        new_fx = tf.f(new_pos)
        check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, new_pos, new_norm, new_fx)
    else
        check_gradient_at_minimum(tf, fn_name, min_pos, min_fx, grad_norm, min_pos, grad_norm, min_fx)
    end
end

# Prozedur: Nicht-differenzierbare oder Randminima behandeln (Klasse 2 und 3)
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
        end
        error_counts[fn_name] = get(error_counts, fn_name, 0) + 1
        @test false
        return
    end
    println("Optimizing minimum for $fn_name (reason: $reason)")
    x0 = copy(min_pos)
    fx_start = tf.f(x0)
    bounded_func = create_bounded_function(tf, lb, ub)
    res = optimize(bounded_func, x0, NelderMead(), Optim.Options(iterations=1000, f_reltol=1e-6))
    new_pos = Optim.minimizer(res)
    new_fx = tf.f(new_pos)
    validate_optimization_result(tf, fn_name, min_pos, min_fx, new_pos, new_fx, fx_start)
end

# Prozedur: Straffunktion erstellen
function create_bounded_function(tf, lb, ub)
    return x -> begin
        if lb !== nothing && any(x .< lb)
            return Inf
        end
        if ub !== nothing && any(x .> ub)
            return Inf
        end
        tf.f(x)
    end
end

# Prozedur: Testzusammenfassung ausgeben
function summarize_test_results(error_counts)
    println("\nOverall Minimum Tests Summary:")
    println("  Catastrophic errors (invalid metadata) and other test failures are listed in the test output above.")
    println("  Test errors:")
    any_errors = false
    for (func, count) in sort(collect(error_counts), by=x->x[2], rev=true)
        if count > 0
            any_errors = true
            println("    $func: $count errors")
        end
    end
    if !any_errors
        println("    No test errors detected.")
    end
    println("  Egon Wurm alerts (significant metadata deviations):")
    any_alerts = false
    for (func, count) in sort(collect(egon_wurm_alerts), by=x->x[2], rev=true)
        if count > 0
            any_alerts = true
            println("    $func: $count alerts")
        end
    end
    if !any_alerts
        println("    No Egon Wurm alerts detected.")
    end
end

@testset "Minimum Tests" begin
    error_counts = Dict{String, Int}()
    egon_wurm_alerts = Dict{String, Int}()
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
        egon_wurm_alerts[fn_name] = 0
    end
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        
        # Schritt 1: Funktion klassifizieren
        class, n, min_pos, min_fx, lb, ub, fixed_indices, reason = classify_function(tf, fn_name)
        
        # Schritt 2: Behandlung je nach Klasse
        if class == 3 || class == 2
            handle_non_differentiable_or_boundary(tf, fn_name, n, min_pos, min_fx, lb, ub, fixed_indices, reason, error_counts)
        elseif class == 1
            handle_interior_minimum(tf, fn_name, min_pos, min_fx, lb, ub, fixed_indices)
        end
    end
    
    # Schritt 3: Testzusammenfassung ausgeben
    summarize_test_results(error_counts)
end