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

@testset "Property Consistency Checks" begin
    # 1. Implikationen (bleiben unverändert)
    implications = Dict(
        "differentiable" => ["continuous"],
        "strongly convex" => ["convex", "differentiable"],
        "quasi-convex" => ["continuous"],
        "highly multimodal" => ["multimodal", "non-convex"],
        "deceptive" => ["non-convex"],
    )

    # 2. Inkompatible Paare – nur in einer Richtung definieren!
    #    Wir machen automatisch beidseitig daraus.
    base_incompatibles = [
        "convex" => ["multimodal", "highly multimodal", "deceptive", "non-convex"],
        "strongly convex" => ["non-convex"],
        "unimodal" => ["multimodal", "highly multimodal"],
        "differentiable" => ["has_noise", "partially differentiable"],
        # Füge hier neue hinzu – nur einmal pro Richtung!
    ]

    # Automatisch alle Kombinationen erzeugen (beidseitig, aber keine Duplikate)
    incompatibles = Set{Tuple{String,String}}()
    for (a, bs) in base_incompatibles
        for b in bs
            push!(incompatibles, (a, b))
            push!(incompatibles, (b, a))  # ← symmetrisch
        end
    end

    all_issues = Tuple{String,String}[]

    for tf in values(TEST_FUNCTIONS)
        props = Set(tf.meta[:properties])
        name = tf.name

        # --- Implikationen prüfen ---
        for (key, required) in implications
            if key in props
                for r in required
                    if r ∉ props
                        push!(all_issues, (name, "$key requires '$r' (missing)"))
                    end
                end
            end
        end

        # --- Inkompatibilitäten prüfen ---
        for (a, b) in incompatibles
            if a in props && b in props && a ≤ b  # nur einmal melden (vermeidet doppelte Meldungen)
                push!(all_issues, (name, "'$a' and '$b' are mutually exclusive"))
            end
        end


    end

    # --- Ergebnis ---
    if !isempty(all_issues)
        println("\n=== Property Consistency Issues ===")
        for (n, msg) in sort!(all_issues; by=first)
            println("$n: $msg")
        end
        println("Total: $(length(all_issues))")
        @test false
    else
        println("All properties consistent")
        @test true
    end
end




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
            @error "Exception in Minimum Validation for $name" exception = (err, catch_backtrace())
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
            should_skip_tiny_test = false
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
            if "bounded" in tf.meta[:properties]
                # Die Untergrenzen (lb) abrufen, die von der Funktion definiert wurden
                local lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()

                # Prüfen, ob eine der Untergrenzen größer als ein sehr kleiner Wert ist (z.B. 1e-10)
                # Ist dies der Fall (wie bei Brad: 0.01), sollte der Test übersprungen werden.
                if any(x -> x > 1e-10, lb)
                    should_skip_tiny_test = true
                end
            end

            if !should_skip_tiny_test
                @test isfinite(tf.f(fill(1e-308, n)))
            end
        catch err
            name = get(tf.meta, :name, "unknown")
            @error "Error in Edge Cases for $name" exception = (err, catch_backtrace())
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
            @error "Error in Zygote Hessian for $name" exception = (err, catch_backtrace())
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


@testset "Start Point Feasibility (within bounds)" begin
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = tf.name

            # Nur bounded Funktionen prüfen
            if !bounded(tf)
                continue
            end

            # Dimension bestimmen (wie in anderen Tests)
            is_scalable = scalable(tf)
            n = if is_scalable
                haskey(tf.meta, :default_n) ? tf.meta[:default_n] : 2
            else
                try
                    length(tf.meta[:min_position]())
                catch
                    2
                end
            end

            # Bounds und Startpunkt holen
            lb_vec = lb(tf, n)
            ub_vec = ub(tf, n)
            x0 = start(tf, n)

            # Prüfen, ob Startpunkt streng innerhalb der Bounds liegt
            # (≥ lb und ≤ ub – aber nicht genau auf der Grenze, da viele Optimizer
            #  interior points erwarten)
            if any(x0 .< lb_vec) || any(x0 .> ub_vec)
                push!(failed_functions, name)
                @warn "Start point OUTSIDE bounds for bounded function '$name'" x0 = x0 lb = lb_vec ub = ub_vec
            end

            # Optional: Warnung, wenn Startpunkt genau auf der Grenze liegt
            # (kann bei manchen Algorithmen (z. B. Fminbox) Probleme machen)
            if any(isapprox.(x0, lb_vec, atol=1e-12)) || any(isapprox.(x0, ub_vec, atol=1e-12))
                @warn "Start point ON boundary for bounded function '$name' (may cause issues with some solvers)" x0 = x0 lb = lb_vec ub = ub_vec
            end

        catch err
            name = get(tf.meta, :name, "unknown")
            @error "Exception while checking start point feasibility for '$name'" exception = (err, catch_backtrace())
            push!(failed_functions, name)
        end
    end

    if !isempty(failed_functions)
        @warn "Start point feasibility check failed for: $(join(failed_functions, ", "))"
        @test false
    else
        println("All bounded functions have feasible (interior or on-boundary) start points.")
        @test true
    end
end


include("gradient_accuracy_tests.jl")
include("minima_tests.jl")
include("l1_penalty_wrapper_tests.jl")
include("include_testfiles.jl")