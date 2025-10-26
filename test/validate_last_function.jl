# validate_last_function.jl
# Purpose: Lädt das Paket, identifiziert die "letzte" Funktion (alphabetisch sortiert nach Namen in TEST_FUNCTIONS),
#         testet sie grob (z. B. f(min_pos) ≈ min_value), validiert den Gradienten an ausgewählten Punkten
#         und berechnet/validiert endgültige Parameter wie min_pos, min_value via REPL-Evaluation.
#         Optimierung (BFGS) nur, wenn Gradient validiert ist (Deviation < 1e-6 an allen Testpunkten).
# Usage: julia --project=. validate_last_function.jl
# Last modified: October 24, 2025

using NonlinearOptimizationTestFunctions
using Test
using Optim  # Für optionale Präzisions-Optimierung
using ForwardDiff  # Für numerische Gradient-Validierung
using LinearAlgebra  # Für norm() in Gradient-Vergleich

function validate_and_refine_last_function()
    # Schritt 1: Identifiziere die "letzte" Funktion (letzte Position in include-Datei)
    # Lese src/NonlinearOptimizationTestFunctions.jl und extrahiere letzte include-Zeile
    include_file = joinpath(@__DIR__, "..", "src", "include_testfunctions.jl")
    
    last_name = nothing
    open(include_file, "r") do io
        for line in eachline(io)
            # Suche nach include("functions/....jl") Zeilen
            m = match(r"include\(\"functions/([^\"]+)\.jl\"\)", line)
            if m !== nothing
                last_name = m.captures[1]  # Extrahiere Funktionsnamen als String
            end
        end
    end
    
    if last_name === nothing
        error("Keine include-Zeile in $include_file gefunden!")
    end
    
    println("Letzte Funktion (letzte Include-Position): $last_name")
    
    tf = TEST_FUNCTIONS[last_name]
    println("Funktion geladen: $(tf.meta[:name])")
    println("Properties: $(tf.meta[:properties])")
    
    # Schritt 2: Bestimme n (fixed oder default_n)
    is_scalable = "scalable" in tf.meta[:properties]
    n = if is_scalable
        get(tf.meta, :default_n, 2)  # Fallback zu 2
    else
        try
            length(tf.meta[:min_position]())
        catch
            2  # Fallback
        end
    end
    println("Verwendete Dimension n: $n")
    
    # Schritt 3: Grob-Test (lade min_pos und min_value) – Variablen außerhalb try für Scope
    min_pos = nothing
    min_value_expected = nothing
    f_val_computed = nothing
    start_pt = nothing
    f_val_at_start = nothing
    
    try
        if is_scalable
            min_pos = tf.meta[:min_position](n)
            min_value_expected = tf.meta[:min_value](n)
            start_pt = tf.meta[:start](n)
        else
            min_pos = tf.meta[:min_position]()
            min_value_expected = tf.meta[:min_value]()
            start_pt = tf.meta[:start]()
        end
        
        f_val_computed = tf.f(min_pos)
        f_val_at_start = tf.f(start_pt)
        
        deviation_min = abs(f_val_computed - min_value_expected)
        println("Grob-Test:")
        println("  min_pos (expected): $min_pos")
        println("  min_value (expected): $min_value_expected")
        println("  f(min_pos) (computed): $f_val_computed")
        println("  Deviation: $deviation_min")
        
        @test deviation_min < 1e-4  # Toleranz erhöht für gerundete Meta-Werte
        println("✅ Grob-Test bestanden (deviation < 1e-4)")
        
        # Test: Startpunkt sollte schlechteren Wert haben als Minimum
        println("\nStartpunkt-Test:")
        println("  start: $start_pt")
        println("  f(start): $f_val_at_start")
        
        if f_val_at_start < f_val_computed - 1e-6
            println("  ⚠️  WARNUNG: f(start) < f(min_pos) - Startpunkt besser als angegebenes Minimum!")
            println("     Dies deutet auf falsches min_value oder min_position hin.")
        elseif abs(f_val_at_start - f_val_computed) < 1e-6
            println("  ⚠️  INFO: f(start) ≈ f(min_pos) - Startpunkt bereits am Minimum")
        else
            println("  ✅ f(start) > f(min_pos) wie erwartet")
        end
        
    catch e
        println("❌ Fehler beim Grob-Test: $e")
        return
    end
    
    # Schritt 4: Gradient-Validierung an Handvoll Punkten (VOR Optimierung!)
    println("\nGradient-Validierung an ausgewählten Punkten (Toleranz: 1e-6):")
    
    # Prüfe erst, ob min_pos in bounds liegt
    lb = is_scalable ? tf.meta[:lb](n) : tf.meta[:lb]()
    ub = is_scalable ? tf.meta[:ub](n) : tf.meta[:ub]()
    
    if !all(min_pos .>= lb) || !all(min_pos .<= ub)
        println("⚠️  WARNUNG: min_pos liegt außerhalb der bounds!")
        println("   min_pos: $min_pos")
        println("   lb: $lb, ub: $ub")
        println("   Dies muss in der Funktionsdefinition korrigiert werden!")
    end
    
    test_points = [
        min_pos,                          # Erwartetes Minimum
        rand(n) .* (ub .- lb) .+ lb,     # Random innerhalb bounds
        fill(1.0, n),                     # Einheitspunkt (wenn in bounds)
        (lb .+ ub) ./ 2                   # Mittelpunkt der bounds
    ]
    
    gradient_ok = true
    for (i, point) in enumerate(test_points)
        println("  Punkt $i: $point")
        
        # Deklariere Variablen außerhalb der try-Blöcke
        anal_grad = nothing
        num_grad = nothing
        
        # Analytischer Gradient
        try
            anal_grad = tf.grad(point)
        catch e
            println("    ❌ Analytischer Gradient fehlgeschlagen: $e")
            gradient_ok = false
            continue  # Fahre mit nächstem Punkt fort
        end
        
        # Numerischer Gradient (via ForwardDiff)
        try
            num_grad = ForwardDiff.gradient(tf.f, point)
        catch e
            println("    ❌ Numerischer Gradient fehlgeschlagen: $e")
            gradient_ok = false
            continue  # Fahre mit nächstem Punkt fort
        end
        
        # Vergleich (nur wenn beide definiert)
        if isnothing(anal_grad) || isnothing(num_grad)
            println("    ❌ Variablen nicht definiert – überspringe Vergleich")
            gradient_ok = false
            continue
        end
        
        grad_dev = norm(anal_grad - num_grad)
        println("    Analytisch: $anal_grad")
        println("    Numerisch: $num_grad")
        println("    Deviation (Norm): $grad_dev")
        
        # Prüfe auf NaN/Inf
        if any(isnan.(anal_grad)) || any(isinf.(anal_grad)) || any(isnan.(num_grad)) || any(isinf.(num_grad))
            println("    ⚠️  NaN/Inf detektiert - Punkt problematisch, aber fahre fort")
            continue  # Überspringe, aber breche nicht ab
        end
        
        if grad_dev > 1e-6
            println("    ❌ Hohe Abweichung – Gradient unzuverlässig!")
            gradient_ok = false
        else
            println("    ✅ Gradient OK")
        end
    end
    
    if !gradient_ok
        println("\n❌ Gradient-Validierung fehlgeschlagen! Optimierung übersprungen – überprüfe Implementierung von tf.grad.")
        return  # Abbruch: Keine Optimierung, wenn Gradient spinnt
    end
    
    println("\n✅ Alle Gradient-Checks bestanden – fahre mit Optimierung fort.")
    
    # Schritt 5: Ermittle endgültige Parameter (präzise Evaluation + optionale Optimierung)
    println("\nEndgültige Parameter-Bestimmung:")
    
    # Präzise f(min_pos) als endgültigen min_value vorschlagen
    precise_min_value = f_val_computed
    println("  Vorgeschlagener präziser min_value: $precise_min_value")
    
    # Optionale Optimierung für noch präziseres Minimum (bei non-convex/multimodal vorsichtig)
    if "multimodal" in tf.meta[:properties]
        println("  Info: Multimodal – starte Optimierung vom bekannten Minimum für beste Konvergenz.")
    end
    
    # Bei multimodalen Funktionen: vom bekannten Minimum starten
    # Wenn min_pos außerhalb bounds: infinitesimal nach innen schieben
    opt_start = copy(min_pos)
    epsilon = 1e-6  # Größeres Epsilon für numerische Stabilität bei Rand-Minima
    
    for i in 1:length(opt_start)
        if opt_start[i] <= lb[i]
            opt_start[i] = lb[i] + epsilon
            println("  ⚠️  min_pos[$i] ≤ lb[$i]: verschoben zu $(opt_start[i]) (Rand-Minimum)")
        elseif opt_start[i] >= ub[i]
            opt_start[i] = ub[i] - epsilon
            println("  ⚠️  min_pos[$i] ≥ ub[$i]: verschoben zu $(opt_start[i]) (Rand-Minimum)")
        end
    end
    
    # Prüfe Gradient am Startpunkt - bei starken Gradienten am Rand warnen
    try
        grad_at_start = tf.grad(opt_start)
        println("  Gradient am Startpunkt: $grad_at_start")
        for i in 1:length(grad_at_start)
            if abs(grad_at_start[i]) > 1.0
                if opt_start[i] ≈ lb[i] + epsilon || opt_start[i] ≈ ub[i] - epsilon
                    println("  ⚠️  Starker Gradient ($(grad_at_start[i])) an Rand-Komponente $i - möglicherweise Rand-Minimum")
                end
            end
        end
    catch e
        println("  ⚠️  Gradient-Check am Startpunkt fehlgeschlagen: $e")
    end
    
    println("  Startpunkt für Optimierung: $opt_start")
    
    # Definiere Objective für Optim (mit Gradient, da validiert)
    # Optim erwartet gradient! in mutierender Form: g!(storage, x)
    objective = (x) -> tf.f(x)
    gradient! = (storage, x) -> copyto!(storage, tf.grad(x))
    
    try
        # Wenn Bounds definiert sind (nicht ±Inf), verwende box-constrained optimizer
        has_finite_bounds = all(isfinite.(lb)) && all(isfinite.(ub))
        
        if has_finite_bounds
            println("  → Verwende Fminbox (box-constrained) wegen endlicher Bounds")
            result = optimize(objective, gradient!, lb, ub, opt_start, Fminbox(BFGS()), 
                            Optim.Options(iterations=1000, f_reltol=1e-10))
        else
            println("  → Verwende BFGS (unbounded)")
            result = optimize(objective, gradient!, opt_start, BFGS(), 
                            Optim.Options(iterations=1000, f_reltol=1e-10))
        end
        
        optimized_min_pos = Optim.minimizer(result)
        optimized_min_value = Optim.minimum(result)
        println("  Optimiertes min_pos: $optimized_min_pos")
        println("  Optimiertes min_value: $optimized_min_value")
        println("  Erfolg: $(Optim.converged(result))")
        
        # Prüfe ob Optimierung sinnvolle Werte liefert
        if any(isnan.(optimized_min_pos)) || any(isinf.(optimized_min_pos)) || isnan(optimized_min_value) || isinf(optimized_min_value)
            println("  ⚠️  Optimierung lieferte NaN/Inf - verwende bekanntes Minimum stattdessen")
            optimized_min_pos = min_pos
            optimized_min_value = f_val_computed
        end
        
        # Schritt 6: Ausgabe für Meta-Update (kopiere in :min_position und :min_value)
        println("\nEmpfohlene Meta-Updates für $last_name:")
        if is_scalable
            println("  :min_position => (n::Int) -> fill($(optimized_min_pos[1]), n),  # Annahme: konstant pro Dim")
            println("  :min_value => (n::Int) -> $(optimized_min_value / n) * n,  # Skalierbar")
        else
            println("  :min_position => () -> $(optimized_min_pos),")
            println("  :min_value => () -> $optimized_min_value,")
        end
    catch e
        println("  ❌ Optimierung fehlgeschlagen: $e")
        println("  Verwende bekannte Werte aus Meta:")
        println("  :min_position => () -> $min_pos,")
        println("  :min_value => () -> $f_val_computed,")
    end
    
    # Zusätzlich: Bounds und Start prüfen
    println("\nWeitere Validierungen:")
    println("  lb: $lb, ub: $ub")
    println("  start: $start_pt")
    println("  min_pos: $min_pos")
    
    @test all(start_pt .>= lb) && all(start_pt .<= ub)  # Bounds-Check
    println("✅ Start in Bounds: $(all(start_pt .>= lb) && all(start_pt .<= ub))")
    
    if !all(min_pos .>= lb) || !all(min_pos .<= ub)
        println("❌ min_pos außerhalb Bounds - muss korrigiert werden!")
    else
        println("✅ min_pos in Bounds")
    end
    
    # Prüfe ob angegebenes min_value präzise genug ist
    if abs(f_val_computed - min_value_expected) > 1e-7
        println("\n⚠️  min_value könnte präziser sein:")
        println("   Aktuell: $min_value_expected")
        println("   Präziser: $f_val_computed")
    end
    
    println("\nFertig! Passe src/functions/$(last_name).jl und test/$(last_name)_tests.jl an.")
end

# Führe aus
validate_and_refine_last_function()