# meta_unifier.jl
# Purpose: Audit + auto-unify meta-fields for all test functions to current rules.
#          Generates patches for inconsistencies; optional auto-replace in .jl files.
# Usage: julia --project=. meta_unifier.jl [auto_fix=true] (for auto-replace; careful!)
# Assumptions: In NonlinearOptimizationTestFunctions project; backups src/functions/!
# Last modified: October 31, 2025 (fixed meta lines with keys; use actual :source; Vector for properties)

using NonlinearOptimizationTestFunctions
using Dates  # For timestamps in backups

# Helper: Determine if scalable and get n
function get_scalable_and_n(tf::TestFunction)
    is_scalable = has_property(tf, "scalable")
    if is_scalable
        n = get(tf.meta, :default_n, 2)
    else
        try
            n = length(tf.meta[:min_position]())
        catch
            n = 2
        end
    end
    return is_scalable, n
end

# Helper: Check meta field signature
function check_field_sig(func::Function, is_scalable::Bool, n::Int)
    no_arg_ok = false
    with_n_ok = false
    try
        func()
        no_arg_ok = true
    catch; end
    try
        func(n)
        with_n_ok = true
    catch; end
    expected_no_arg = !is_scalable
    consistent = (no_arg_ok == expected_no_arg) && with_n_ok == is_scalable
    return (no_arg_ok, with_n_ok, consistent)
end

# Helper: Get current value safely
function get_current_value(func::Function, is_scalable::Bool, n::Int)
    if !is_scalable
        try
            return func()
        catch
            try
                return func(n)
            catch
                return nothing
            end
        end
    else
        try
            return func(n)
        catch
            return nothing
        end
    end
end

# Helper: Generate correct meta line for a field (now with key)
function generate_meta_line(field::Symbol, value, is_scalable::Bool, n::Int)
    if field == :default_n
        return ":default_n => $value,"
    end
    if is_scalable
        sig = "(n::Int) -> "
        if isa(value, AbstractVector)
            if length(value) == 1  # Assume constant per dim
                val_str = "fill($(value[1]), n)"
            else
                val_str = "fill($(value[1]), n)"  # Or adapt for n-dependent
            end
        elseif isa(value, Number)
            val_str = "$value"  # Constant
        else
            val_str = "nothing"  # Fallback
        end
    else
        sig = "() -> "
        if isa(value, AbstractVector)
            val_str = "[$(join(map(x -> replace(string(x), r"\"" => "\\\""), value), ", "))]"
        elseif isa(value, Number)
            val_str = "$value"
        else
            val_str = "nothing"
        end
    end
    return ":$field => $sig$val_str,"  # [RULE_META_CONSISTENCY]
end

# Audit and generate patches
function unify_metas(auto_fix::Bool=false)
    functions = collect(values(TEST_FUNCTIONS))
    patches = Dict{String, String}()  # filename => full replacement code
    missing_default_n = String[]

    println("Unifying metas for $(length(functions)) functions...")

    for tf in functions
        name = tf.meta[:name]
        filename = "src/functions/$(name).jl"
        is_scalable, n = get_scalable_and_n(tf)

        # Check/add default_n for scalable
        if is_scalable && !haskey(tf.meta, :default_n)
            push!(missing_default_n, name)
        end

        # Check relevant fields
        fields_to_check = [:lb, :ub, :start, :min_position, :min_value]
        needs_patch = false
        meta_lines = ":name => \"$name\",\n"
        if is_scalable
            default_n = get(tf.meta, :default_n, 2)
            meta_lines *= generate_meta_line(:default_n, default_n, true, n) * "\n"
        end
        # Static fields (use actual values)
        meta_lines *= ":description => \"$(get(tf.meta, :description, "Updated per rules"))\",\n"
        meta_lines *= ":math => raw\"\"\"$(get(tf.meta, :math, "f(\\mathbf{x}) = ..."))\"\"\",\n"  # Use actual if present
        # Properties as Vector{String}, not Set
        props = isa(tf.meta[:properties], Set) ? collect(tf.meta[:properties]) : tf.meta[:properties]
        meta_lines *= ":properties => [\"$(join(props, "\", \""))\"],\n"
        actual_source = get(tf.meta, :source, "Jamil & Yang (2013, p. XX)")
        meta_lines *= ":source => \"$actual_source\",\n"

        for field in fields_to_check
            if haskey(tf.meta, field)
                no_arg_ok, with_n_ok, consistent = check_field_sig(tf.meta[field], is_scalable, n)
                if !consistent
                    needs_patch = true
                end
                # Always generate line (unify all to current sig)
                curr_val = get_current_value(tf.meta[field], is_scalable, n)
                if curr_val !== nothing
                    line = generate_meta_line(field, curr_val, is_scalable, n)
                    meta_lines *= "    $line\n"
                else
                    println("Warning: Can't extract value for :$field in $name – skip.")
                end
            else
                println("Warning: Missing :$field in $name – add manually from source.")
                needs_patch = true
            end
        end

        if needs_patch || (is_scalable && !haskey(tf.meta, :default_n))
            upper_name = uppercase(name)
            grad_name = name * "_gradient"
            full_patch = string("const ", upper_name, "_FUNCTION = TestFunction(\n",
                "    ", name, ",\n",
                "    ", grad_name, ",\n",
                "    Dict(\n",
                "        ", meta_lines,
                "    )\n",
                ")")
            patches[filename] = full_patch
        end
    end

    # Output
    if isempty(patches) && isempty(missing_default_n)
        println("✅ All metas unified! Run tests to confirm.")
        return
    end

    println("\n## Generated Patches (copy-paste/replace const _FUNCTION block in .jl):")
    for (file, patch) in sort(collect(patches))
        println("\n### $file:")
        println(patch)
        println("\n---")  # Separator
    end

    if !isempty(missing_default_n)
        println("\n## Scalable w/o :default_n (add to meta Dict):")
        for fname in sort(missing_default_n)
            println("- $fname: `:default_n => 2,` (adjust if block-scaled, e.g. 4)")
        end
    end

    if auto_fix
        println("\n⚠️  Auto-fixing (BACKUP src/functions/ first!)...")
        backup_dir = "src/functions_backup_$(Dates.format(now(), "yyyymmdd_HHMMSS"))"
        mkpath(backup_dir)
        for (file, patch) in patches
            full_path = joinpath(pwd(), file)
            if isfile(full_path)
                content = read(full_path, String)
                # Backup
                cp(full_path, joinpath(backup_dir, basename(file)))
                # Replace: Find const UPPER_FUNCTION = ... ; replace block
                upper_name = uppercase(split(basename(file), '.')[1])  # From filename
                regex_str = "const\\s+" * upper_name * "\\s*=\\s*TestFunction\\s*\\((.*?)\\)\\s*(?=const|\\Z)"
                regex_match = match(Regex(regex_str, "si"), content)
                if regex_match !== nothing
                    new_content = replace(content, regex_match.match => patch)
                    write(full_path, new_content)
                    println("Fixed $file (backup in $backup_dir)")
                else
                    println("Warning: Could not match block in $file – manual patch.")
                end
            end
        end
    end

    println("\nPost-unify: Reload package (`]dev .`) & run `test/runtests.jl`. For :math/:source, fill from Jamil & Yang PDF via tool if needed.")
end

# Run (set auto_fix=true for auto; false for manual)
unify_metas(false)