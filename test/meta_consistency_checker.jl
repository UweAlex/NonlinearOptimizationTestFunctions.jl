# full_auditor.jl
# Purpose: Audit default_n + properties + source + non-scalable meta calls.
# Usage: julia --project=. full_auditor.jl
# Last modified: October 31, 2025 (lint v6: fixed unbalanced quotes in filter; "not in" to "!(... in ...)")

using NonlinearOptimizationTestFunctions

# VALID_PROPERTIES
VALID_PROPERTIES = Set(["bounded", "continuous", "controversial", "convex", "deceptive", "differentiable", "finite_at_inf", "fully non-separable", "has_constraints", "has_noise", "highly multimodal", "multimodal", "non-convex", "non-separable", "partially differentiable", "partially separable", "quasi-convex", "scalable", "separable", "strongly convex", "unimodal", "ill-conditioned"])

# Audit default_n (scalable only)
function audit_default_n(all_tfs)
    scalable = filter(tf -> "scalable" in tf.meta[:properties], all_tfs)
    println("=== Default_n Audit ===")
    println("Scalable functions: $(length(scalable))")
    println("| Name | :default_n | Valid? |")
    println("|------|------------|--------|")
    invalid = []
    for tf in scalable
        name = tf.meta[:name]
        dn = get(tf.meta, :default_n, missing)
        valid = !ismissing(dn) && dn >= 2 ? "Yes" : "No (missing or <2)"
        println("| $name | $dn | $valid |")
        if valid == "No (missing or <2)"
            push!(invalid, name)
        end
    end
    println("\nInvalid default_n: $(length(invalid)) / $(length(scalable))")
    if !isempty(invalid)
        println("Flag: $(join(invalid, ", ")) – add :default_n => 2 in meta.")
    else
        println("All good!")
    end
    return invalid
end

# Audit properties
function audit_properties(all_tfs)
    println("\n=== Properties Audit ===")
    println("| Name | Type | Valid? |")
    println("|------|------|--------|")
    invalid = []
    for tf in all_tfs
        name = tf.meta[:name]
        props = tf.meta[:properties]
        type_str = string(typeof(props))
        valid = true
        issues = []
        if isa(props, Bool)
            valid = false
            push!(issues, "Bool (fix to Array)")
        elseif isa(props, Union{Set, AbstractVector})
            props_list = isa(props, Set) ? collect(props) : props
            inv = filter(p -> !(lowercase(string(p)) in VALID_PROPERTIES), props_list)
            if !isempty(inv)
                valid = false
                push!(issues, "Invalid: $(join(inv, ", "))")
            end
        else
            valid = false
            push!(issues, "Wrong type: $type_str")
        end
        status = valid ? "Yes" : "No ($(join(issues, "; ")))"
        println("| $name | $type_str | $status |")
        if !valid
            push!(invalid, name)
        end
    end
    println("\nInvalid properties: $(length(invalid)) / $(length(all_tfs))")
    if !isempty(invalid)
        println("Flag: $(join(invalid, ", ")) – fix :properties to Array from VALID_PROPERTIES.")
    else
        println("All good!")
    end
    return invalid
end

# Audit source
function audit_source(all_tfs)
    println("\n=== Source Audit ===")
    println("| Name | Source | Valid? |")
    println("|------|--------|--------|")
    invalid = []
    detail_missing = []
    for tf in all_tfs
        name = tf.meta[:name]
        source = get(tf.meta, :source, "missing")
        valid = source != "missing" && !isempty(source) ? "Yes" : "No (missing)"
        detail = occursin(r"p\.\s*\d+|Section\s+\d+", source) ? "Yes" : "Detail missing"
        status = valid == "Yes" ? detail : valid
        println("| $name | $source | $status |")
        if valid == "No (missing)"
            push!(invalid, name)
        elseif detail == "Detail missing"
            push!(detail_missing, name)
        end
    end
    println("\nInvalid source: $(length(invalid)) / $(length(all_tfs))")
    if !isempty(invalid)
        println("Flag (missing): $(join(invalid, ", ")) – add :source => 'Jamil & Yang (2013)'.")
    end
    println("\nMissing detail (p./Section): $(length(detail_missing)) / $(length(all_tfs))")
    if !isempty(detail_missing)
        println("Flag (detail): $(join(detail_missing, ", ")) – add 'p. XX' or 'Section X'.")
    else
        println("All good!")
    end
    return invalid, detail_missing
end

# Audit non-scalable meta calls
function audit_non_scal_meta(all_tfs)
    non_scal = filter(tf -> !("scalable" in tf.meta[:properties]), all_tfs)
    println("\n=== Non-Scalable Meta Audit (must be () callable) ===")
    println("Non-scalable functions: $(length(non_scal))")
    println("| Name | Issues | Details |")
    println("|------|--------|---------|")
    flagged = []
    for tf in non_scal
        name = tf.meta[:name]
        issues = []
        for f in [:lb, :ub, :start, :min_position, :min_value]
            if haskey(tf.meta, f)
                func = tf.meta[f]
                if try func(); false catch _ true end  # Throws = sig = (n::Int) -> ...
                    push!(issues, string(f))
                end
            end
        end
        num = length(issues)
        status = num > 0 ? "Flagged ($num issues)" : "OK"
        println("| $name | $status | $(join(issues, ", ")) |")
        if num > 0
            push!(flagged, name)
        end
    end
    println("\nFlagged (inconsistent sig): $(length(flagged)) / $(length(non_scal))")
    if !isempty(flagged)
        println("Flag: $(join(flagged, ", ")) – fix to () -> fixed_value in meta.")
    else
        println("All good!")
    end
    return flagged
end

# Main: Run all
function main()
    all_tfs = collect(values(TEST_FUNCTIONS))
    println("Total functions: $(length(all_tfs))\n")
    audit_default_n(all_tfs)
    audit_properties(all_tfs)
    audit_source(all_tfs)
    audit_non_scal_meta(all_tfs)
end

main()