# check_missing_source.jl
# Purpose: Überprüft alle Julia-Dateien in src/functions/ auf Vorkommen von ":source" im Meta-Dict.
# Run: julia --project=. check_missing_source.jl
# Output: Liste der Dateien, die KEIN ":source" enthalten (case-sensitive Suche).

using Pkg

# Pfad zum src/functions-Verzeichnis (angenommen, du bist im Projekt-Root)
functions_dir = joinpath(@__DIR__, "src", "functions")

if !isdir(functions_dir)
    error("Verzeichnis $functions_dir nicht gefunden. Starte das Skript im Projekt-Root.")
end

# Alle .jl-Dateien laden und nach ":source" suchen
files_without_source = String[]
for file in readdir(functions_dir, join=true)
    if endswith(file, ".jl")
        content = read(file, String)
        if !occursin(":source", content)
            push!(files_without_source, basename(file))
            println("❌ Kein :source gefunden in: $(basename(file))")
        end
    end
end

# Zusammenfassung
println("\n--- Zusammenfassung ---")
total_files = length(readdir(functions_dir))
if isempty(files_without_source)
    println("✅ Alle $(total_files) Dateien enthalten :source.")
else
    println("⚠️  Fehlendes :source in $(length(files_without_source)) Dateien: $(join(files_without_source, ", "))")
    println("Betroffene von $(total_files) Dateien.")
end

# Optional: Vollständige Liste aller Dateien ausgeben
println("\nGesamte Dateien: $(join(basename.(readdir(functions_dir)), ", "))")