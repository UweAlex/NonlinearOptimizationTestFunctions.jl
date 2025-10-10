# remove_in_molga_smutnicki_from_functions_v1.jl
# Purpose: Searches all test function files and removes the line ":in_molga_smutnicki_2005 => false," if present.
# Usage: julia --project=. remove_in_molga_smutnicki_from_functions_v1.jl

using NonlinearOptimizationTestFunctions
using Dates

function remove_in_molga_if_present_v1()
    backup_dir = "backups_remove_in_molga_v1_$(Dates.format(now(), "yyyy-mm-dd_HH-MMSS"))"
    mkpath(backup_dir)
    println("Backup directory: $backup_dir")

    modified_count = 0
    skipped_count = 0
    for (name, tf) in TEST_FUNCTIONS
        println("Processing function '$name' – checking for :in_molga_smutnicki_2005")
        
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
        
        # Find and remove lines containing ":in_molga_smutnicki_2005 => false,"
        removed = false
        new_lines = []
        for line in lines
            if occursin(r":in_molga_smutnicki_2005\s*=>", line) && occursin("false,", line)
                println("  Found and removing line: $line")
                removed = true
            else
                push!(new_lines, line)
            end
        end
        
        if removed
            # Write back
            write(filepath, join(new_lines, "\n") * "\n")
            println("  Removed from $filepath")
            modified_count += 1
        else
            println("  No matching line found – no changes.")
        end
    end
    
    println("\nDone! Modified $modified_count files, skipped $skipped_count. Reload and test!")
end

remove_in_molga_if_present_v1()