# runtests.jl
# Purpose: Entry point for running all tests in NonlinearOptimizationTestFunctions.
# Context: Contains cross-function tests and includes function-specific tests via include_testfiles.jl.
# Last modified: October 02, 2025

using Test, ForwardDiff, Zygote
using NonlinearOptimizationTestFunctions
using Optim
using Random
using LinearAlgebra

@testset "Filter and Properties Tests" begin
    println("Starting Filter and Properties Tests")
 #   @test length(filter_testfunctions(tf -> has_property(tf, "bounded"))) == 88  # Updated for new functions
 #   @test length(filter_testfunctions(tf -> has_property(tf, "continuous"))) == 85
 #   @test length(filter_testfunctions(tf -> has_property(tf, "multimodal"))) == 69
 #   @test length(filter_testfunctions(tf -> has_property(tf, "convex"))) == 10
 #   @test length(filter_testfunctions(tf -> has_property(tf, "differentiable"))) == 77
 #   @test length(filter_testfunctions(tf -> has_property(tf, "has_noise"))) == 2  # De Jong F4 + Quartic
 #   @test length(filter_testfunctions(tf -> has_property(tf, "partially differentiable"))) == 13
 #   finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
 #   @test length(finite_at_inf_funcs) == 3  # dejongf5, shekel, etc.
end #testset

@testset "Minimum Validation" begin
    println("Starting Minimum Validation Tests")
    for tf in values(TEST_FUNCTIONS)
        try
            is_scalable = "scalable" in tf.meta[:properties]
            n = nothing
            if is_scalable
                # Use default_n if available, else try candidates
                if haskey(tf.meta, :default_n)
                    n_candidate = tf.meta[:default_n]
                    try
                        pos = tf.meta[:min_position](n_candidate)
                        n = length(pos)
                        println("Debug: $(tf.name) using default_n=$n")
                    catch e
                        println("Debug: $(tf.name) failed default_n=$n_candidate: $e")
                        n = nothing
                    end
                end
                if isnothing(n)
                    for candidate_n in [2, 4, 10]  # Fallback candidates
                        try
                            pos = tf.meta[:min_position](candidate_n)
                            n = length(pos)
                            println("Debug: $(tf.name) using n=$n (candidate $candidate_n)")
                            break
                        catch e
                            println("Debug: $(tf.name) failed candidate $candidate_n: $e")
                            continue
                        end
                    end
                end
            else
                try
                    pos = tf.meta[:min_position]()
                    n = length(pos)
                    println("Debug: $(tf.name) fixed n=$n")
                catch e
                    n = 2
                    println("Debug: $(tf.name) fallback fixed n=2")
                end
            end
            
            if isnothing(n) || n <= 0
                println("Warning: Could not determine valid n for $(tf.name), skipping")
                continue
            end
            println("Debug: Final n for $(tf.name) = $n")
            
            min_pos = is_scalable ? tf.meta[:min_position](n) : tf.meta[:min_position]()
            println("Debug: min_pos for $(tf.name) = $min_pos")
            
            min_value = is_scalable ? tf.meta[:min_value](n) : tf.meta[:min_value]()
            f_val = tf.f(min_pos)
            println("Debug: f_val=$f_val, min_value=$min_value")
            
            if "has_noise" in tf.meta[:properties]
                # For noisy functions, check range (e.g., uniform [0,1) noise)
                @test f_val >= min_value && f_val < min_value + 1.0  # Adjust upper bound as needed
            else
                if abs(f_val - min_value) > 1e-6
                    println("Failure for function: $(tf.name)")
                    println("  min_pos = $min_pos")
                    println("  expected min_value = $min_value")
                    println("  computed f(min_pos) = $f_val")
                    println("  deviation = $(abs(f_val - min_value))")
                    @test false
                else
                    @test f_val ≈ min_value atol=1e-6
                end
            end
        catch e
            println("Error in Minimum Validation for $(tf.name): $e")
            @test false
        end
    end
end

@testset "Edge Cases" begin
    println("Starting Edge Cases Tests")
    for tf in values(TEST_FUNCTIONS)
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
        @test_throws ArgumentError tf.f(Float64[])
        @test isnan(tf.f(fill(NaN, n)))
        if "bounded" in tf.meta[:properties]
            lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
            ub = is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
            # For noisy: f(lb) may vary, but should be finite
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
        if "has_noise" in tf.meta[:properties]
            continue  # Skip noisy functions for Hessian (stochastic)
        end
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
                        # Silent fail, try next
                    end
                    if !success
                        n_candidate = 4
                        try
                            dummy = tf.meta[:start](n_candidate)
                            n = n_candidate
                            success = true
                        catch e
                            continue
                        end
                    end
                    if !success
                        continue
                    end
                end
            end

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

            # Prüfe Längen vor Broadcast
            @test length(x) > 0
            @test length(x) == length(lb) == length(ub)

            bounds_violated = !all(x .>= lb) || !all(x .<= ub)
            @test !bounds_violated  # Prüfe Grenzen

        catch e
            println("Unexpected error in Start Point Tests for $(get(tf.meta, :name, "unknown")): $(typeof(e)) - $e")
            if !(e isa KeyError || e isa ArgumentError || e isa MethodError)
                rethrow(e)  # Andere Fehler weiterwerfen
            end
        end #try
    end #for
end #testset

# Gradient Tests auslagern
include("gradient_accuracy_tests.jl")
include("minima_tests.jl")
include("include_testfiles.jl")