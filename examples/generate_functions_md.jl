# examples/generate_functions_md.jl
# Purpose: Dynamically generate FUNCTIONS.md with vertical block formatting and TOC from TEST_FUNCTIONS.
# Also updates a compact list for README.md.
# Run: julia --project=. examples/generate_functions_md.jl
# Last modified: October 21, 2025

using NonlinearOptimizationTestFunctions
using Dates

# Safe call for meta functions with try-catch
function safe_meta_call(func::Function, n::Int, fallback)
    try
        func(n)
    catch e
        @warn "Error calling meta function with n=$n: $e. Using fallback."
        fallback
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
        # Fallback strategy: Try n=2, then n=4 if fails
        try
            tf.meta[:min_position](2)  # Test if n=2 works
            return 2
        catch
            try
                tf.meta[:min_position](4)
                return 4
            catch e
                @warn "No valid n for $(tf.meta[:name]): $e. Using fallback n=2."
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
    # Extrahiere Werte (Fallbacks für fehlende Meta; handle scalable vs non-scalable)
    formula = get(tf.meta, :math, raw"Placeholder: f(\mathbf{x}) = \dots")
    lb_func = get(tf.meta, :lb, () -> fill(-100.0, n))
    min_pos_func = get(tf.meta, :min_position, () -> zeros(n))
    min_val_func = get(tf.meta, :min_value, () -> 0.0)
    props_raw = tf.meta[:properties]
    if isa(props_raw, String)
        props = split(props_raw, ", "; keepempty=false)
    else
        props = collect(props_raw)
    end
    props_str = join(props, ", ")
    ref = get(tf.meta, :source, "Unknown")

    is_scalable = "scalable" in props
    lb = safe_meta_call(lb_func, n, fill(-100.0, n))
    min_pos = safe_meta_call(min_pos_func, n, zeros(n))
    min_val = safe_meta_call(min_val_func, n, 0.0)

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