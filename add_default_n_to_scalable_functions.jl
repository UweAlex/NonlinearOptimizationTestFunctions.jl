# add_default_n_to_scalable_functions_v3.jl
# Improved: Searches for :properties line and inserts after it (handles multi-line Dicts).
# Usage: julia --project=. add_default_n_to_scalable_functions_v3.jl

using NonlinearOptimizationTestFunctions
using Dates

function add_default_n_if_missing_v3()
    backup_dir = "backups_v3_$(Dates.format(now(), "yyyy-mm-dd_HH-MMSS"))"
    mkpath(backup_dir)
    println("Backup directory: $backup_dir")

    modified_count = 0
    skipped_count = 0
    for (name, tf) in TEST_FUNCTIONS
        meta = tf.meta
        if "scalable" in meta[:properties] && !haskey(meta, :default_n)
            println("Processing scalable function '$name' – adding :default_n => 2")
            
            filename = lowercase(name) * ".jl"
            filepath = joinpath("src", "functions", filename)
            
            if !isfile(filepath)
                println("  Warning: File $filepath not found – skipping.")
                skipped_count += 1
                continue
            end
            
            # Backup
            backup_path = joinpath(backup_dir, filename * ".bak")
            cp(filepath, backup_path)
            println("  Backed up to $backup_path")
            
            # Read lines
            lines = readlines(filepath)
            
            # Find :properties line
            properties_idx = nothing
            for (i, line) in enumerate(lines)
                if occursin(r":properties\s*=>", line)
                    properties_idx = i
                    break
                end
            end
            if isnothing(properties_idx)
                println("  Warning: No :properties line found – skipping.")
                skipped_count += 1
                continue
            end
            
            # Find insert position: After the properties block (next non-empty/comma line)
            insert_idx = properties_idx + 1
            while insert_idx <= length(lines) && (isempty(strip(lines[insert_idx])) || occursin(r"^\s*,\s*$", strip(lines[insert_idx])))
                insert_idx += 1
            end
            
            # Insert new line
            new_line = "        :default_n => 2,"
            insert!(lines, insert_idx, new_line)
            
            # Write back
            write(filepath, join(lines, "\n") * "\n")
            println("  Added to $filepath")
            modified_count += 1
        end
    end
    
    println("\nDone! Modified $modified_count files, skipped $skipped_count. Reload and test!")
end

add_default_n_if_missing_v3()