# duplicate_detector.jl
# Purpose: Detects potential duplicate test functions by comparing function values at zero and 3 random points.
# Usage: Save this as duplicate_detector.jl in your project root and run: julia --project=. duplicate_detector.jl
# Assumptions: Runs in the NonlinearOptimizationTestFunctions project environment.
# Last modified: October 31, 2025 (debugged: fixed safe meta calls for lb/ub in random_point; added more debug)

using NonlinearOptimizationTestFunctions
using Random
using LinearAlgebra  # For norm if needed, but not used here

# Helper: Get dimension (copied/adapted from package logic)
function get_n(tf::TestFunction)
    if has_property(tf, "scalable")
        return -1  # Scalable
    else
        try
            return length(tf.meta[:min_position]())
        catch e
            @warn "Could not determine dimension for $(tf.meta[:name]): $e. Assuming 2."
            return 2
        end
    end
end

# Helper: Get a suitable n for evaluation (use default_n if available, else 2 for scalable)
function get_eval_n(tf::TestFunction)
    dim = get_n(tf)
    if dim == -1  # Scalable
        if haskey(tf.meta, :default_n)
            return tf.meta[:default_n]
        else
            return 2  # Fallback
        end
    else
        return dim
    end
end

# New Helper: Safe meta call (handles () vs (n::Int) signatures)
function safe_meta_call(func::Function, is_scalable::Bool, n::Int, fallback)
    if !is_scalable
        try
            return func()
        catch e
            if isa(e, MethodError)
                try
                    return func(n)
                catch e2
                    @warn "Error calling meta function (tried () and (n)): $e2. Using fallback."
                    return fallback
                end
            else
                @warn "Error calling meta function (): $e. Using fallback."
                return fallback
            end
        end
    else
        try
            return func(n)
        catch e
            @warn "Error calling meta function (n): $e. Using fallback."
            return fallback
        end
    end
end

# Helper: Generate a random point in bounds if available, else randn scaled
function random_point(tf::TestFunction, n::Int)
    if has_property(tf, "bounded") && haskey(tf.meta, :lb) && haskey(tf.meta, :ub)
        is_scalable = has_property(tf, "scalable")
        lb_fallback = fill(-100.0, n)  # Reasonable default
        ub_fallback = fill(100.0, n)
        
        lb = safe_meta_call(tf.meta[:lb], is_scalable, n, lb_fallback)
        ub = safe_meta_call(tf.meta[:ub], is_scalable, n, ub_fallback)
        
        # Debug: Log if fallback used
        if length(lb) != n || any(lb .== lb_fallback)
            println("Debug: Using fallback bounds for $(tf.meta[:name]) (lb=$lb, ub=$ub)")
        end
        
        return lb .+ rand(n) .* (ub .- lb)
    else
        # Fallback: randn in [-5, 5] or similar
        return 10 * randn(n)
    end
end

# Main detection logic
function find_duplicates(atol::Float64=1e-6, num_random_points::Int=3)
    functions = collect(values(TEST_FUNCTIONS))
    num_funcs = length(functions)
    duplicates = Pair{String, String}[]

    println("Scanning $(num_funcs) functions for duplicates (atol=$atol)...")
    Random.seed!(42)  # For reproducibility

    progress_counter = 0
    for i in 1:num_funcs
        tf1 = functions[i]
        name1 = tf1.meta[:name]  # Fixed: tf1 instead of tf
        n1 = get_eval_n(tf1)
        progress_counter += 1
        if progress_counter % 20 == 0 || progress_counter == num_funcs  # Debug: Progress every 20 funcs
            println("Debug: Processed $progress_counter / $num_funcs outer functions (current: $name1, n=$n1)")
        end

        for j in (i+1):num_funcs  # Avoid self-comparison and duplicates
            tf2 = functions[j]
            name2 = tf2.meta[:name]  # Fixed: tf2 instead of tf
            n2 = get_eval_n(tf2)

            # Skip if dimensions don't match
            if n1 != n2
                continue
            end

            n = n1  # Use common n

            # Evaluate at zero
            x0 = zeros(n)
            f1_0 = tf1.f(x0)
            f2_0 = tf2.f(x0)
            if !isapprox(f1_0, f2_0, atol=atol)
                continue
            end

            # Debug: Log zero-match (rare, so informative)
            println("Debug: Zero-match for '$name1' (f=$f1_0) vs '$name2' (f=$f2_0) at n=$n")

            # Generate and evaluate at random points
            all_match = true
            for k in 1:num_random_points
                x_rand = random_point(tf1, n)  # Use tf1's bounds as proxy
                f1_rand = tf1.f(x_rand)
                f2_rand = tf2.f(x_rand)
                if !isapprox(f1_rand, f2_rand, atol=atol)
                    all_match = false
                    println("Debug: Mismatch at random point $k for '$name1' vs '$name2': f1=$f1_rand, f2=$f2_rand (x=$x_rand)")
                    break
                end
            end

            if all_match
                push!(duplicates, name1 => name2)
                println("Potential duplicate found: '$name1' and '$name2' (n=$n)")
            end
        end
    end

    if isempty(duplicates)
        println("No duplicates detected.")
    else
        println("\nSummary of potential duplicates:")
        for (name1, name2) in sort(duplicates)
            println("  - $name1 ↔ $name2")
        end
    end
end

# Run the detector
find_duplicates()