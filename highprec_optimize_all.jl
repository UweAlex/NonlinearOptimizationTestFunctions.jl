# highprec_optimize_all.jl
# Purpose: Geht alle TestFunctions durch, optimiert jede mit hoher Präzision (BigFloat + enge Toleranzen),
# um präzisere :min_position und :min_value zu bekommen (bis letzte Float64-Stelle).
# Ersetzt diese Werte im Quellcode (src/functions/<name>.jl) im TestFunction-Dict.
# Run: julia --project=. highprec_optimize_all.jl
# Backup: src/functions/ vorab sichern! (cp -r src/functions src/functions_backup)
# Voraussetzungen: using Optim, BigFloat (in Paket: add Optim falls nötig)
# Hinweise:
# - Für noisy: Überspringt (z.B. "has_noise" in properties).
# - Für constrained: Überspringt (hat_constraints).
# - Skalierbare: Nutzt :default_n oder fallback 2/4.
# - Optimiert von :start oder aktueller :min_position.
# - Präzision: BigFloat(128 bits ~38 Stellen), dann zu Float64 runden.
# - Log: highprec_log.txt; Ersetzungen: highprec_changes.txt

using NonlinearOptimizationTestFunctions
using Optim
using BigFloat  # Für hohe Präzision

# Setze hohe Präzision
const HIGH_PREC_BITS = 128  # ~38 Dezimalstellen; erhöhe für mehr (langsamer)

# Hilfsfunktion: Bestimme n für Optimierung
function get_n_for_opt(tf::TestFunction)
    if "scalable" in tf.meta[:properties]
        if haskey(tf.meta, :default_n)
            return tf.meta[:default_n]
        else
            # Fallback: Probiere 2, dann 4
            for cand in [2, 4]
                try
                    length(tf.meta[:min_position](cand))
                    return cand
                catch
                    continue
                end
            end
            error("Kein gültiges n für $(tf.meta[:name]) gefunden.")
        end
    else
        try
            return length(tf.meta[:min_position]())
        catch
            return 2  # Fallback
        end
    end
end

# Hilfsfunktion: Optimiere mit High-Prec (BigFloat)
function highprec_optimize(tf::TestFunction, n::Int)
    setprecision(HIGH_PREC_BITS)
    
    # Starte von :start oder :min_position (als BigFloat)
    start_big = try
        BigFloat.(tf.meta[:start](n))
    catch
        BigFloat.(tf.meta[:min_position](n))  # Fallback
    end
    
    # Bounds falls vorhanden
    lb_big = try
        BigFloat.(tf.meta[:lb](n))
    catch
        nothing
    end
    ub_big = try
        BigFloat.(tf.meta[:ub](n))
    catch
        nothing
    end
    
    # Wrapper für Optim (BigFloat -> Float64 für Optim, aber interne f/grad mit BigFloat)
    function obj_big(x::Vector{Float64})
        x_big = BigFloat.(x)
        return Float64(tf.f(x_big))
    end
    function grad_big!(g::Vector{Float64}, x::Vector{Float64})
        x_big = BigFloat.(x)
        g_big = tf.grad(x_big)
        g .= Float64.(g_big)
    end
    
    # Optimierung
    opts = Optim.Options(
        x_abstol=1e-15,  # Hohe Präzision
        f_abstol=1e-15,
        g_abstol=1e-15,
        iterations=1000,
        store_trace=false
    )
    
    if lb_big !== nothing && ub_big !== nothing
        # Bounded
        result = optimize(obj_big, grad_big!, lb_big, ub_big, start_big, Fminbox(LBFGS()), opts)
    else
        # Unbounded
        result = optimize(obj_big, grad_big!, start_big, LBFGS(), opts)
    end
    
    # Extrahiere Ergebnisse als Float64
    min_pos = Float64.(Optim.minimizer(result))
    min_val = Float64(Optim.minimum(result))
    
    return min_pos, min_val
end

# Hilfsfunktion: Ersetze im Quellcode (Text-Parsing)
function replace_in_source(name::String, min_pos::Vector{Float64}, min_val::Float64)
    filename = "$name.jl"
    path = joinpath("src/functions", filename)
    if !isfile(path)
        @warn "Datei $path nicht gefunden."
        return false
    end
    
    lines = readlines(path)
    new_lines = String[]
    replaced_pos = false
    replaced_val = false
    
    for line in lines
        # Ersetze :min_position => () -> [old_values],
        if occursin(r":min_position\s+=>\s+\(\)\s+->\s+\[([^\]]+)\]", line)
            # Extrahiere Werte und ersetze mit neuen (format: [1.0, 2.0, ...])
            new_vals = join([@sprintf("%.15g", v) for v in min_pos], ", ")
            new_line = replace(line, r"\[([^\]]+)\]" => "[$new_vals]")  # Ersetzt den Inhalt
            push!(new_lines, new_line)
            replaced_pos = true
        elseif occursin(r":min_position\s+=>\s+\(n::Int\)\s+->\s+begin.*?\[([^\]]+)\]", line)  # Für scalable (vereinfacht)
            new_vals = join([@sprintf("%.15g", v) for v in min_pos], ", ")
            new_line = replace(line, r"\[([^\]]+)\]" => "[$new_vals]")  # Annahme: fill oder direkt
            push!(new_lines, new_line)
            replaced_pos = true
        # Ersetze :min_value => () -> old_val,
        elseif occursin(r":min_value\s+=>\s+\(\)\s+->\s+([0-9.e+-]+)", line)
            new_line = replace(line, r"([0-9.e+-]+)" => @sprintf("%.15g", min_val))
            push!(new_lines, new_line)
            replaced_val = true
        elseif occursin(r":min_value\s+=>\s+\(n::Int\)\s+->\s+([0-9.e+-]+)", line)  # Für konstante scalable
            new_line = replace(line, r"([0-9.e+-]+)" => @sprintf("%.15g", min_val))
            push!(new_lines, new_line)
            replaced_val = true
        else
            push!(new_lines, line)
        end
    end
    
    if replaced_pos || replaced_val
        write(path, join(new_lines, "\n") * "\n")
        open("highprec_changes.txt", "a") do f
            write(f, "$name: min_pos = $min_pos, min_val = $min_val\n")
        end
        println("✓ $name: Ersetzt (pos: $replaced_pos, val: $replaced_val)")
        return true
    else
        @warn "Keine Ersetzung für $name (Parsing-Fehler?)."
        return false
    end
end

# Hauptlogik
println("Starte High-Prec-Optimierung aller TestFunctions... (Backup empfohlen!)")
open("highprec_log.txt", "w") do f
    write(f, "High-Prec Log: $(Dates.now())\n")
end

skipped = 0
optimized = 0
for (name, tf) in sort(collect(TEST_FUNCTIONS); by=first)
    try
        # Überspringe noisy/constrained
        if "has_noise" in tf.meta[:properties] || "has_constraints" in tf.meta[:properties]
            println("- $name übersprungen (noisy/constrained).")
            skipped += 1
            continue
        end
        
        n = get_n_for_opt(tf)
        println("Optimiere $name (n=$n)...")
        
        min_pos, min_val = highprec_optimize(tf, n)
        
        # Validierung: f(min_pos) ≈ min_val?
        f_check = tf.f(min_pos)
        if abs(f_check - min_val) > 1e-12
            @warn "$name: Validierung fehlgeschlagen (f=$f_check vs min_val=$min_val)"
        end
        
        # Ersetze im Code
        replace_in_source(name, min_pos, min_val)
        optimized += 1
        
        open("highprec_log.txt", "a") do f
            write(f, "$name (n=$n): min_pos=$min_pos, min_val=$min_val, f_check=$f_check\n")
        end
        
    catch e
        @error "Fehler bei $name: $e"
        open("highprec_log.txt", "a") do f
            write(f, "$name: FEHLER - $e\n")
        end
        skipped += 1
    end
end

println("\nFertig! $optimized optimiert/ersetzt, $skipped übersprungen.")
println("Logs: highprec_log.txt (Ergebnisse), highprec_changes.txt (Änderungen).")
println("Nächste Schritte: 1. git diff src/functions/ prüfen. 2. test/runtests.jl ausführen.")