# examples/generate_functions_md.jl
# Purpose: Dynamically generate FUNCTIONS.md with alphabetical list of functions and their details from TEST_FUNCTIONS.
# Includes name, description, formula, bounds/minimum, properties, and reference for each function.
# Run: julia --project=. examples/generate_functions_md.jl
# Last modified: November 15, 2025

using NonlinearOptimizationTestFunctions
using Dates

# Safe call for meta functions with try-catch
function safe_meta_call(func::Function, is_scalable::Bool, n::Int, fallback)
    if !is_scalable
        try
            func()
        catch e
            if isa(e, MethodError)
                try
                    func(n)
                catch e2
                    @warn "Error calling meta function (tried () and (n)): $e2. Using fallback."
                    fallback
                end
            else
                @warn "Error calling meta function (): $e. Using fallback."
                fallback
            end
        end
    else
        try
            func(n)
        catch e
            @warn "Error calling meta function (n): $e. Using fallback."
            fallback
        end
    end
end

# Get dimension with validation
function get_dimension(tf::TestFunction)
    if haskey(tf.meta, :default_n)
        default_n = tf.meta[:default_n]
        if default_n < 1
            @warn "Invalid default_n $default_n for $(tf.meta[:name]). Falling back to 2."
            return 2
        end
        return default_n
    else
        # Try () for non-scalable
        try
            min_pos = tf.meta[:min_position]()
            return length(min_pos)
        catch e
            if isa(e, MethodError)
                # Scalable, try n=2
                try
                    tf.meta[:min_position](2)
                    return 2
                catch e2
                    if isa(e2, ArgumentError)
                        # Try n=4 for block
                        try
                            tf.meta[:min_position](4)
                            return 4
                        catch e3
                            @warn "No valid n for $(tf.meta[:name]): $e3. Using fallback n=2."
                            return 2
                        end
                    else
                        @warn "Unexpected error for $(tf.meta[:name]): $e2. Using fallback n=2."
                        return 2
                    end
                end
            else
                @warn "Unexpected error for $(tf.meta[:name]): $e. Using fallback n=2."
                return 2
            end
        end
    end
end

# Generiere einen Block pro Funktion (vertikale Bullet-Formatierung)
function generate_block(tf::TestFunction)
    n = get_dimension(tf)
    is_scalable = "scalable" in tf.meta[:properties]
    # Fallbacks
    lb_fallback = fill(-100.0, n)
    min_pos_fallback = fill(0.0, n)
    min_val_fallback = 0.0

    # Extrahiere Werte
    formula = get(tf.meta, :math, raw"Placeholder: f(\mathbf{x}) = \dots")
    desc = get(tf.meta, :description, "No description available.")
    lb_func = get(tf.meta, :lb, () -> lb_fallback)
    min_pos_func = get(tf.meta, :min_position, () -> min_pos_fallback)
    min_val_func = get(tf.meta, :min_value, () -> min_val_fallback)
    props_raw = tf.meta[:properties]
    if isa(props_raw, String)
        props = split(props_raw, ", "; keepempty=false)
    else
        props = collect(props_raw)
    end
    props_str = join(props, ", ")
    ref = get(tf.meta, :source, "Unknown")

    lb = safe_meta_call(lb_func, is_scalable, n, lb_fallback)
    min_pos = safe_meta_call(min_pos_func, is_scalable, n, min_pos_fallback)
    min_val = safe_meta_call(min_val_func, is_scalable, n, min_val_fallback)

    bounds_str = "Bounds: [$(join(lb, ", "))]"
    min_str = "Min: $min_val at $min_pos"

    block = """
### $(tf.meta[:name])
- **Description**: $desc
- **Formula**: $formula
- **Bounds/Minimum**: $bounds_str; $min_str
- **Properties**: $props_str
- **Reference**: $ref
"""
    return block
end

# Hauptfunktion: Schreibe FUNCTIONS.md mit alphabetischer Liste
function generate_functions_md()
    # Sortiere Funktionen alphabetisch nach Name
    funcs = sort(collect(values(TEST_FUNCTIONS)); by = tf -> tf.meta[:name])
    
    open("FUNCTIONS.md", "w") do io
        write(io, "# Alphabetical List of Benchmark Functions\n\n")
        write(io, "Generated from package metadata on $(Dates.format(now(), "yyyy-mm-dd")). Functions are listed alphabetically with their details.\n\n")
        
        # Alphabetische Liste ohne Kategorien
        for tf in funcs
            block = generate_block(tf)
            write(io, "$block\n\n")
        end
        
        write(io, "## Generation\nRun `julia --project=. examples/generate_functions_md.jl` to update from TEST_FUNCTIONS.\n")
    end
    println("Generated FUNCTIONS.md with alphabetical list including descriptions and details.")
end

# Ausführen
generate_functions_md()