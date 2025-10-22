# examples/generate_functions_md.jl
# Purpose: Dynamically generate FUNCTIONS.md with vertical block formatting and TOC from TEST_FUNCTIONS.
# Also updates a compact list for README.md.
# Run: julia --project=. examples/generate_functions_md.jl
# Last modified: October 21, 2025

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

# Hilfsfunktion: Kategorisiere basierend auf Properties (anpassen nach Bedarf)
function categorize(tf::TestFunction)
    props_raw = tf.meta[:properties]
    # Sicherstellen, dass props iterierbar ist (Vector/Set, nicht String)
    if isa(props_raw, String)
        props = split(props_raw, ", "; keepempty=false)
    else
        props = collect(props_raw)  # Zu Vector konvertieren
    end
    if "unimodal" in props && !("multimodal" in props) && !("has_noise" in props)
        return "Classical Benchmarks"
    elseif any(p in props for p in ["multimodal", "has_noise", "non-convex"])
        return "Extended Benchmarks"
    else
        return "Other Benchmarks"
    end
end

# Generiere einen Block pro Funktion (vertikale Bullet-Formatierung)
function generate_block(tf::TestFunction, variant::String)
    n = get_dimension(tf)
    is_scalable = "scalable" in tf.meta[:properties]
    # Fallbacks
    lb_fallback = fill(-100.0, n)
    min_pos_fallback = fill(0.0, n)
    min_val_fallback = 0.0

    # Extrahiere Werte
    formula = get(tf.meta, :math, raw"Placeholder: f(\mathbf{x}) = \dots")
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
### $(tf.meta[:name]): $variant
- **Formula**: $formula
- **Bounds/Minimum**: $bounds_str; $min_str
- **Properties**: $props_str
- **Reference**: $ref
"""
    return block
end

# Generiere TOC (Nested List)
function generate_toc(by_category::Dict{String, Vector{TestFunction}})
    toc = ["## Inhaltsverzeichnis"]
    for (cat, funcs) in sort(collect(by_category); by = first)
        push!(toc, "- [$cat](#$(lowercase(replace(cat, " " => "-"))))")
        for tf in sort(funcs, by = tf -> tf.meta[:name])
            variant = length(split(tf.meta[:name], "_")) > 1 ? split(tf.meta[:name], "_")[end] : "Standard"
            variant = String(variant)  # Ensure String
            link = lowercase(replace("$(tf.meta[:name])-$variant", r"\s+" => "-"))
            push!(toc, "  - [$(tf.meta[:name]): $variant](#$link)")
        end
    end
    join(toc, "\n")
end

# Hauptfunktion: Schreibe FUNCTIONS.md
function generate_functions_md()
    # Gruppiere nach Kategorie
    by_category = Dict{String, Vector{TestFunction}}()
    for tf in values(TEST_FUNCTIONS)
        cat = categorize(tf)
        if !haskey(by_category, cat)
            by_category[cat] = TestFunction[]
        end
        push!(by_category[cat], tf)
    end

    open("FUNCTIONS.md", "w") do io
        write(io, "# Established Benchmark Functions\n\n")
        write(io, "Generated from package metadata on $(Dates.format(now(), "yyyy-mm-dd")). Functions are listed vertically by category for easy reading.\n\n")
        
        # TOC
        toc = generate_toc(by_category)
        write(io, "$toc\n\n")
        
        # Abschnitte mit Blöcken
        for (cat, funcs) in sort(collect(by_category); by = first)
            cat_id = lowercase(replace(cat, " " => "-"))
            write(io, "## $cat {#$cat_id}\n\n")
            for tf in sort(funcs, by = tf -> tf.meta[:name])
                variant = length(split(tf.meta[:name], "_")) > 1 ? split(tf.meta[:name], "_")[end] : "Standard"
                variant = String(variant)  # Ensure String
                link_id = lowercase(replace("$(tf.meta[:name])-$variant", r"\s+" => "-"))
                block = generate_block(tf, variant)
                # Füge ID zum Header hinzu
                header_line = "### $(tf.meta[:name]): $variant {#$link_id}"
                write(io, replace(block, "### $(tf.meta[:name]): $variant" => header_line))
                write(io, "\n\n")
            end
        end
        
        write(io, "## Generation\nRun `julia --project=. examples/generate_functions_md.jl` to update from TEST_FUNCTIONS.\n")
    end
    println("Generated FUNCTIONS.md")
end

# Update README: Kompakte Bullet-Liste (alphabetisch gruppiert, erste 20 detailliert)
function update_readme_list()
    funcs = sort(collect(values(TEST_FUNCTIONS)); by = tf -> tf.meta[:name])
    bullets = String[]
    
    # Gruppiere alphabetisch (A-B, C-E, etc.)
    current_group = ""
    group_funcs = String[]
    for tf in funcs
        first_letter = uppercase(tf.meta[:name][1])
        if first_letter != current_group
            if !isempty(group_funcs)
                push!(bullets, "### $current_group\n" * join(group_funcs, "\n") * "\n")
            end
            current_group = first_letter
            group_funcs = String[]
        end
        desc = split(get(tf.meta, :description, "Benchmark function"), ";")[1]  # Kurze Desc
        push!(group_funcs, "- **$(tf.meta[:name])**: $desc.")
    end
    if !isempty(group_funcs)
        push!(bullets, "### $current_group\n" * join(group_funcs, "\n"))
    end
    
    # Wenn >20, kürze und "Weitere..."
    if length(funcs) > 20
        push!(bullets, "### Weitere Funktionen (F–Z)\n- [Liste aller, z.B. deb1, rastrigin, ...]")
    end
    
    list_md = join(bullets, "\n")
    println("README List Preview:\n$list_md\n---\nFüge das manuell in README.md unter 'Test Functions' ein oder automatisiere mit File-IO (z.B. replace).")
end

# Ausführen
generate_functions_md()
update_readme_list()