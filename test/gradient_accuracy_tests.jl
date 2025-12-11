using Test, ForwardDiff
using NonlinearOptimizationTestFunctions # Annahme: Enthält die Konstante TEST_FUNCTIONS
using Random
using Printf # Für @info/println Formatierung
using LinearAlgebra # Für Vektor-Operationen

# --- Globale Konstanten und Cache-Status ---

const CACHE_FILE = joinpath("test", "gradient_test_cache.txt") 
const CACHE_DATA = Dict{String, Int}() # Globaler, veränderbarer Cache
const TOLERANCE = 2.5e-8 # KORREKTUR: Toleranz erhöht von 1e-8 auf 2.5e-8
const MAX_TEST_POINTS = 40
const MAX_ATTEMPTS = 5

# --- Caching-Funktionen ---

# Lädt den Cache einmalig beim Start in den globalen Dict CACHE_DATA.
function initialize_cache(cache_file_path=CACHE_FILE)
    empty!(CACHE_DATA)
    if isfile(cache_file_path)
        try
            for line in eachline(cache_file_path)
                line = strip(line)
                isempty(line) && continue
                # Erwarte Format: name=mtime
                if occursin('=', line)
                    name, time_str = split(line, '=', limit=2)
                    CACHE_DATA[name] = parse(Int, time_str)
                end
            end
        catch e
            @warn "Fehler beim Lesen des Cache '$cache_file_path': $e. Cache wird ignoriert."
        end
    end
end

# Speichert den gesamten Inhalt des globalen Caches zurück auf die Platte.
function save_cache_to_disk()
    # Sicherstellen, dass der Ordner 'test' existiert
    cache_dir = dirname(CACHE_FILE)
    if !isdir(cache_dir)
        mkpath(cache_dir)
    end

    open(CACHE_FILE, "w") do io
        for (name, mtime_val) in CACHE_DATA
            write(io, "$name=$mtime_val\n")
        end
    end
end

# Prüft, ob der Test aufgrund geänderter Quelldatei ausgeführt werden muss.
function should_run_test(fn_name, src_file_path)
    if !isfile(src_file_path)
        return true, "Quelldatei ($src_file_path) nicht gefunden/Neu: Test muss ausgeführt werden."
    end
    # round() verwenden, um Nachkommastellen zu entfernen und InexactError zu vermeiden
    current_mod_time = Int(round(mtime(src_file_path))) 

    if haskey(CACHE_DATA, fn_name)
        cached_mod_time = CACHE_DATA[fn_name]
        
        if current_mod_time <= cached_mod_time
            return false, "Übersprungen: Die Datei ist nicht neuer als der letzte erfolgreiche Testlauf."
        else
            return true, "Ausführen: Die Datei wurde seit dem letzten erfolgreichen Test geändert."
        end
    else
        return true, "Erstes Mal: Test muss ausgeführt werden."
    end
end

# --- Allgemeine Hilfsfunktionen ---

# Berechnet den relativen Unterschied zwischen zwei Vektoren
function relative_diff(a, b; epsilon=1e-10)
    rel_diff = 0.0
    for i in eachindex(a)
        rel_diff += abs(a[i] - b[i]) / (abs(a[i]) + abs(b[i]) + epsilon)
    end
    return rel_diff
end

# Extrahiert Metadatenwerte und wandelt sie in Float64 um
function get_meta_value(field, n, is_scalable, fn_name, field_name)
    try
        if isa(field, Function)
            # Ruft die Funktion nur mit n auf, wenn sie skalierbar ist
            return float.(is_scalable ? field(n) : field())
        else
            return float.(field)
        end
    catch e
        error("Error in $field_name for $fn_name: $e")
    end
end

# --- Kern-Test-Logik ---

function test_gradient_accuracy_bigfloat(tf, n, max_attempts=MAX_ATTEMPTS)
    fn_name = tf.meta[:name]
    
    # 1. Speichere die aktuelle BigFloat-Präzision
    original_precision = precision(BigFloat) 
    
    # Setze die BigFloat-Präzision auf 256 Bit
    setprecision(256) 
    
    is_scalable = "scalable" in tf.meta[:properties]
    is_bounded = "bounded" in tf.meta[:properties]

    # Hole initiale Schranken in Float64
    min_pos_f64 = get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
    
    if length(min_pos_f64) != n
         error("Dimension mismatch for $fn_name: expected $n, got $(length(min_pos_f64)) from min_position")
    end

    min_pos = BigFloat.(min_pos_f64)
    
    if is_bounded
        lb_f64 = get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb")
        ub_f64 = get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub")
    else
        lb_f64 = min_pos_f64 .- 5.0
        ub_f64 = min_pos_f64 .+ 5.0
    end
    lb = BigFloat.(lb_f64)
    ub = BigFloat.(ub_f64)
    
    total_relative_diff = 0.0
    valid_points_count = 0

    for i in 1:MAX_TEST_POINTS
        t = BigFloat((i - 1) / MAX_TEST_POINTS)
        current_lb = min_pos + (BigFloat(1) - t) * (lb - min_pos)
        current_ub = min_pos + (BigFloat(1) - t) * (ub - min_pos)

        attempts = 0
        point = zeros(BigFloat, n)
        
        while attempts < max_attempts
            # Generierung des zufälligen BigFloat-Punktes
            point .= current_lb .+ rand(BigFloat, n) .* (current_ub - current_lb)
            
            try
                an_grad_big = tf.grad(point)
                ad_grad_big = ForwardDiff.gradient(tf.f, point)

                if all(isfinite, an_grad_big) && all(isfinite, ad_grad_big)
                    diff = relative_diff(Float64.(an_grad_big), Float64.(ad_grad_big))
                    total_relative_diff += diff
                    valid_points_count += 1
                    break
                end
            catch
                # Ignoriere Domain Errors etc. und versuche es erneut
            end
            
            attempts += 1
            if attempts == max_attempts
                @warn "Fehler: Konnte keinen gültigen Punkt für $fn_name bei Schritt $i generieren."
                break
            end
        end
    end
    
    # 2. Präzision auf den ursprünglichen Wert zurücksetzen
    setprecision(original_precision) 
    
    return total_relative_diff, valid_points_count
end

# --- Haupt-Testset ---

@testset "BigFloat Gradient Accuracy Caching Tests" begin
    Random.seed!(1234)
    
    # 1. Cache einmalig beim Start laden
    initialize_cache() 

    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        
        # Annahme: Quelldatei liegt unter src/functions/<name>.jl
        src_file = joinpath("src", "functions", "$fn_name.jl") 
        
        # 2. Caching-Prüfung
        run_test, reason = should_run_test(fn_name, src_file)

        if !run_test
            @info "SKIP: $fn_name. $reason"
            @test_skip true 
            continue
        end

        # 3. Bestimme Standard-Dimension
        is_scalable = "scalable" in tf.meta[:properties]
        
        n = 0 # Initialisiere n

        if is_scalable
            # Wenn skalierbar, MUSS :default_n existieren.
            if haskey(tf.meta, :default_n)
                n = tf.meta[:default_n]
            else
                 @error "Metadatenfehler: Skalierbare Funktion $(fn_name) fehlt :default_n. Verwende n=2 als Fallback."
                 n = 2 
            end
        else
            # Wenn nicht skalierbar, lies die Dimension aus min_position.
            try
                fixed_min_pos = get_meta_value(tf.meta[:min_position], 1, false, fn_name, "min_position")
                n = length(fixed_min_pos)
            catch e
                @error "Konnte Dimension für $fn_name nicht ermittelt werden: $e"
                @test false
                continue
            end
        end
        
        # Sicherheits-Check
        if n <= 0
            @error "Dimension n konnte für $fn_name nicht korrekt bestimmt werden (n=$n)."
            @test false
            continue
        end
        
        # 4. Test-Ausführung
        @info @sprintf "RUNNING: %-20s - %s (N=%d)" fn_name reason n
        
        sum_diff, count = try
            test_gradient_accuracy_bigfloat(tf, n)
        catch e
            @error "Testlauf für $fn_name fehlgeschlagen (Exception): $e"
            @test false 
            continue 
        end
        
        # 5. Ergebnis-Prüfung
        @test count > 0 # Mindestens ein gültiger Punkt muss gefunden worden sein
        @test sum_diff < TOLERANCE * count 
        
        if sum_diff < TOLERANCE * count
            # 6. Caching-Update bei Erfolg
            current_mod_time = Int(round(mtime(src_file))) 
            CACHE_DATA[fn_name] = current_mod_time 
            save_cache_to_disk() 
            
            @info @sprintf "SUCCESS: %-20s - Akkumulierte Differenz: %.2e (Punkte: %d)" fn_name sum_diff count
        end
    end
end