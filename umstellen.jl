# umstellen.jl (angepasst: Keine Dict-Änderungen)
# Purpose: Automatisch alle src/functions/*.jl auf BigFloat-Support umstellen.
# Ändert NUR: where-Klausel (BigFloat hinzufügen), Konstanten zu T(k).
# Kein Touching von Meta-Dict oder :properties!
# Run: julia --project=. umstellen.jl
# Backup: src/functions/ vorab sichern!

using Dates

# Pfade
functions_dir = "src/functions"
log_file = "umstellungs_log.txt"

# Hilfsfunktion: Datei lesen/schreiben
function process_file(filename::String)
    path = joinpath(functions_dir, filename)
    if !isfile(path)
        println("Warnung: Datei $path nicht gefunden.")
        return false
    end
    
    lines = readlines(path)
    modified = false
    new_lines = String[]
    i = 1  # Zeilen-Index für präzises Einfügen
    
    while i <= length(lines)
        line = lines[i]
        
        # 1. Erweitere where-Klausel für f und grad (füge BigFloat hinzu)
        if occursin(r"function\s+(\w+)\(x::AbstractVector<T\>\)\s+where\s+\{T<:\w+Union\{Real,\s*ForwardDiff\.Dual", line)
            # Ersetze: where {T<:Union{Real, ForwardDiff.Dual}} -> where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
            new_line = replace(line, r"where\s+\{T<:\w+Union\{Real,\s*ForwardDiff\.Dual" => "where {T<:Union{Real, ForwardDiff.Dual, BigFloat")
            if new_line != line
                push!(new_lines, "# High-Prec angepasst: $new_line")  # Kommentar für Klarheit
                modified = true
                i += 1  # Weiter
            else
                push!(new_lines, line)
                i += 1
            end
        elseif occursin(r"function\s+(\w+)_gradient\(x::AbstractVector<T\>\)\s+where\s+\{T<:\w+Union\{Real,\s*ForwardDiff\.Dual", line)
            new_line = replace(line, r"where\s+\{T<:\w+Union\{Real,\s*ForwardDiff\.Dual" => "where {T<:Union{Real, ForwardDiff.Dual, BigFloat")
            if new_line != line
                push!(new_lines, "# High-Prec angepasst: $new_line")
                modified = true
                i += 1
            else
                push!(new_lines, line)
                i += 1
            end
        # 2. Füge optionalen Präzisions-Check nach Edge-Cases hinzu (nach "any(isinf.(x))")
        elseif occursin(r"any\(isinf\.\(x\)\)\s+\&\&\s+return\s+(fill\()?T\(Inf\)", line)
            push!(new_lines, line)
            # Prüfe, ob der Check schon da ist (nächste Zeilen)
            next_i = i + 1
            has_check = false
            while next_i <= length(lines) && occursin(r"^\s*(if|end|\#)", lines[next_i])
                if occursin(r"if T <: BigFloat", lines[next_i])
                    has_check = true
                    break
                end
                next_i += 1
            end
            if !has_check
                # Füge ein: if T <: BigFloat; setprecision(256); end
                push!(new_lines, "    if T <: BigFloat")
                push!(new_lines, "        setprecision(256)  # Optional: Passe an gewünschte Bits an")
                push!(new_lines, "    end")
                modified = true
            end
            i += 1  # Weiter zum nächsten Block
        # 3. Ersetze harte Konstanten zu T(k) in mathematischen Ausdrücken (z.B. 2 * -> T(2) *)
        elseif occursin(r"(\b\d+\b)\s+\*\s+(?!T\()", line)  # Integer-Multiplikation, nicht schon T(k)
            # Ersetze 1* -> T(1)*, 2* -> T(2)* usw. (Lookahead für Nicht-T(k))
            new_line = replace(line, r"(\b(\d+)\b)\s+\*\s+" => s"T(\2) * ")
            # Nur anwenden, wenn in Kontext (z.B. sum, term, grad, Schleife)
            if new_line != line && (occursin(r"sum|term|grad|\+=|\[i\]|@inbounds", new_line) || occursin(r"sum|term|grad|\+=|\[i\]|@inbounds", line))
                push!(new_lines, new_line)
                modified = true
            else
                push!(new_lines, line)
            end
            i += 1
        else
            push!(new_lines, line)
            i += 1
        end
    end
    
    if modified
        write(path, join(new_lines, "\n") * "\n")
        open(log_file, "a") do f
            write(f, "$(now()): $filename modifiziert (where + Konstanten angepasst; Dict unberührt).\n")
        end
        println("✓ $filename umgestellt.")
    else
        println("- $filename unverändert (bereits kompatibel?).")
    end
    return modified
end

# Hauptlogik: Alle .jl-Dateien in src/functions/ verarbeiten
println("Starte Umstellung von $(functions_dir)... (Backup empfohlen! Dict bleibt unverändert.)")
open(log_file, "w") do f
    write(f, "Umstellungs-Log (Dict-sicher): $(now())\n")
end

files = filter(f -> endswith(f, ".jl") && f != "TestFunction.jl", readdir(functions_dir))  # Alle Funktionsdateien
num_processed = 0
num_modified = 0
for file in sort(files)
    if process_file(file)
        num_modified += 1
    end
    num_processed += 1
end

println("\nFertig! $num_processed Dateien verarbeitet, davon $num_modified modifiziert.")
println("Log: $log_file")
println("Nächste Schritte: 1. Teste Syntax: julia --project=. -e 'using NonlinearOptimizationTestFunctions'")
println("2. Benchmarks: @btime tf.f(rand(6)) für eine Funktion (sollte unverändert sein)")
println("3. High-Prec-Test: using BigFloat; setprecision(256); tf.f(BigFloat.(rand(6)))")