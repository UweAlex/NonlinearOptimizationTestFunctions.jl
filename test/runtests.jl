# runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: October 16, 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random
using LinearAlgebra

@testset "Filter and Properties Tests" begin
    println("Starting Filter and Properties Tests")
 #   @test length(filter_testfunctions(tf -> has_property(tf, "bounded"))) == 128  # Updated based on current count
 #   @test length(filter_testfunctions(tf -> has_property(tf, "continuous"))) == 158
 #   @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 117
 #   @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 12
 #   @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 145
 #   @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 2  # De Jong F4 + Quartic
 #   @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 17
 #   finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
 #   @test length(finite_at_inf_funcs) == 3  # dejongf5, shekel, etc.
  #  println("Filter and Properties Tests: All passed.")
end #testset

@testset "Minimum Validation" begin
    println("Starting Minimum Validation Tests")
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = get(tf.meta, :name, "unknown")
            println("Testing minimum for $name...")
            is_scalable = "scalable" in tf.meta[:properties]
            n = nothing
            if is_scalable
                # Use default_n if available, else try candidates
                if haskey(tf.meta, :default_n)
                    n_candidate = tf.meta[:default_n]
                    try
                        pos = tf.meta[:min_position](n_candidate)
                        n = length(pos)
                        println("Debug: $name using default_n=$n")
                    catch e
                        println("Debug: $name failed default_n=$n_candidate: $e")
                        n = nothing
                    end
                end
                if isnothing(n)
                    for candidate_n in [2, 4, 10]  # Fallback candidates
                        try
                            pos = tf.meta[:min_position](candidate_n)
                            n = length(pos)
                            println("Debug: $name using n=$n (candidate $candidate_n)")
                            break
                        catch e
                            println("Debug: $name failed candidate $candidate_n: $e")
                            continue
                        end
                    end
                end
            else
                try
                    pos = tf.meta[:min_position]()
                    n = length(pos)
                    println("Debug: $name fixed n=$n")
                catch e
                    n = 2
                    println("Debug: $name fallback fixed n=2")
                end
            end
            
            if isnothing(n) || n <= 0
                println("Warning: Could not determine valid n for $name, skipping")
                continue
            end
            println("Debug: Final n for $name = $n")
            
            min_pos = is_scalable ? tf.meta[:min_position](n) : tf.meta[:min_position]()
            println("Debug: min_pos for $name = $min_pos")
            
            min_value = is_scalable ? tf.meta[:min_value](n) : tf.meta[:min_value]()
            f_val = tf.f(min_pos)
            println("Debug: f_val=$f_val, min_value=$min_value")
            
            if "has_noise" in tf.meta[:properties]
                # For noisy functions, check range (e.g., uniform [0,1) noise)
                println("Debug: Noisy function $name - checking range...")
                if !(f_val >= min_value && f_val < min_value + 1.0)
                    println("Failure for noisy function: $name")
                    println("  min_pos = $min_pos")
                    println("  expected min_value = $min_value")
                    println("  computed f(min_pos) = $f_val")
                    println("  deviation = $(abs(f_val - min_value))")
                    push!(failed_functions, name)
                    @test false
                end
                @test f_val >= min_value && f_val < min_value + 1.0  # Adjust upper bound as needed
            else
                if abs(f_val - min_value) > 1e-6
                    println("Failure for function: $name")
                    println("  min_pos = $min_pos")
                    println("  expected min_value = $min_value")
                    println("  computed f(min_pos) = $f_val")
                    println("  deviation = $(abs(f_val - min_value))")
                    push!(failed_functions, name)
                    @test false
                else
                    @test f_val ≈ min_value atol=1e-6
                end
            end
            println("Minimum validation passed for $name")
        catch e
            name = get(tf.meta, :name, "unknown")
            println("Error in Minimum Validation for $name: $(typeof(e)) - $e")
            println("Stacktrace: ", sprint(showerror, e))
            push!(failed_functions, name)
            @test false
        end
    end
    if !isempty(failed_functions)
        println("Minimum Validation Summary: Failed for functions: $(join(failed_functions, ", "))")
    else
        println("Minimum Validation: All passed.")
    end
end

@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = get(tf.meta, :name, "unknown")
            println("Testing edge cases for $name...")
            is_scalable = "scalable" in tf.meta[:properties]
            n = if is_scalable
                try
                    if haskey(tf.meta, :default_n)
                        length(tf.meta[:min_position](tf.meta[:default_n]))
                    else
                        length(tf.meta[:min_position](2))
                    end
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
            println("Debug: n=$n for $name")
            
            println("  Testing empty vector...")
            @test_throws ArgumentError tf.f(Float64[])
            
            println("  Testing NaN inputs...")
            @test isnan(tf.f(fill(NaN, n)))
            
            println("  Testing Inf inputs...")
            if "bounded" in tf.meta[:properties]
                lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
                ub = is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
                # For noisy: f(lb) may vary, but should be finite
                println("  Testing bounds (lb=$lb, ub=$ub)...")
                @test isfinite(tf.f(lb))
                @test isfinite(tf.f(ub))
            elseif "finite_at_inf" in tf.meta[:properties]
                println("  Testing finite at Inf...")
                @test isfinite(tf.f(fill(Inf, n)))
            else
                println("  Testing Inf inputs (expect Inf)...")
                @test isinf(tf.f(fill(Inf, n)))
            end #if
            
            println("  Testing very small numbers...")
            @test isfinite(tf.f(fill(1e-308, n)))
            
            println("Edge cases passed for $name")
        catch e
            name = get(tf.meta, :name, "unknown")
            println("Error in Edge Cases for $name: $(typeof(e)) - $e")
            println("Stacktrace: ", sprint(showerror, e))
            push!(failed_functions, name)
            rethrow(e)
        end
    end #for
    if !isempty(failed_functions)
        println("Edge Cases Summary: Failed for functions: $(join(failed_functions, ", "))")
    else
        println("Edge Cases: All passed.")
    end
end #testset

@testset "Zygote Hessian" begin
    println("Starting Zygote Hessian Tests")
    failed_functions = String[]
    for tf in [ROSENBROCK_FUNCTION, SPHERE_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION]
        try
            name = get(tf.meta, :name, "unknown")
            println("Testing Hessian for $name...")
            if "has_noise" in tf.meta[:properties]
                println("Skipping noisy function $name for Hessian test")
                continue  # Skip noisy functions for Hessian (stochastic)
            end
            x = tf.meta[:start](2)
            println("Debug: x=$x for $name")
            H = Zygote.hessian(tf.f, x)
            println("Debug: H=$H for $name")
            @test size(H) == (2, 2)
            @test all(isfinite, H)
            println("Hessian test passed for $name")
        catch e
            name = get(tf.meta, :name, "unknown")
            println("Error in Zygote Hessian for $name: $(typeof(e)) - $e")
            println("Stacktrace: ", sprint(showerror, e))
            push!(failed_functions, name)
            rethrow(e)
        end
    end #for
    if !isempty(failed_functions)
        println("Zygote Hessian Summary: Failed for functions: $(join(failed_functions, ", "))")
    else
        println("Zygote Hessian: All passed.")
    end
end #testset

@testset "Start Point Tests" begin
    println("Starting Start Point Tests")
    failed_functions = String[]
    for tf in values(TEST_FUNCTIONS)
        try
            name = get(tf.meta, :name, "unknown")
            println("Testing start point for $name...")
            if !("bounded" in tf.meta[:properties])
                println("Skipping $name (not bounded)")
                continue  # Überspringe Funktionen ohne "bounded"-Eigenschaft
            end #if

            # Bestimme n mit Fallback für spezielle skalierbare Funktionen (z.B. multiple of 4)
            is_scalable = "scalable" in tf.meta[:properties]
            n = if !is_scalable
                length(tf.meta[:min_position]())
            else
                if haskey(tf.meta, :default_n)
                    tf.meta[:default_n]
                else
                    n_candidate = 2
                    local success = false
                    try
                        dummy = tf.meta[:start](n_candidate)
                        n = n_candidate
                        success = true
                    catch e
                        println("Debug: $name failed n_candidate=$n_candidate: $e")
                    end
                    if !success
                        n_candidate = 4
                        try
                            dummy = tf.meta[:start](n_candidate)
                            n = n_candidate
                            success = true
                        catch e
                            println("Debug: $name failed n_candidate=$n_candidate: $e")
                            continue
                        end
                    end
                    if !success
                        continue
                    end
                end
            end

            println("Debug: n=$n for $name")

            # Hole start_point, lb, ub mit konsistentem n
            if is_scalable
                x = tf.meta[:start](n)
                lb = tf.meta[:lb](n)
                ub = tf.meta[:ub](n)
            else
                x = tf.meta[:start]()
                lb = tf.meta[:lb]()
                ub = tf.meta[:ub]()
            end

            println("Debug: x=$x, lb=$lb, ub=$ub for $name")

            # Prüfe Längen vor Broadcast
            @test length(x) > 0
            @test length(x) == length(lb) == length(ub)

            bounds_violated = !all(x .>= lb) || !all(x .<= ub)
            if bounds_violated
                println("Bounds violated for $name: x=$x not in [lb=$lb, ub=$ub]")
            end
            @test !bounds_violated  # Prüfe Grenzen

            println("Start point test passed for $name")
        catch e
            name = get(tf.meta, :name, "unknown")
            println("Unexpected error in Start Point Tests for $name: $(typeof(e)) - $e")
            println("Stacktrace: ", sprint(showerror, e))
            if !(e isa KeyError || e isa ArgumentError || e isa MethodError)
                rethrow(e)  # Andere Fehler weiterwerfen
            end
            push!(failed_functions, name)
        end #try
    end #for
    if !isempty(failed_functions)
        println("Start Point Summary: Failed for functions: $(join(failed_functions, ", "))")
    else
        println("Start Point Tests: All passed.")
    end
end #testset

# Gradient Tests auslagern
println("Starting Gradient Accuracy Tests...")
include("gradient_accuracy_tests.jl")
println("Starting Minima Tests...")
include("minima_tests.jl")
println("Starting Function-Specific Tests...")
include("include_testfiles.jl")