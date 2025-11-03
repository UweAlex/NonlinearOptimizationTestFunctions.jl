# ==============================================================================
# Juggluco Datenabruf-Programm in Julia (Zyklische Version)
# ZWECK: Sicheres Abrufen von Glukose- und Behandlungsdaten von Juggluco
# ZIEL: Kleines, extrem gut kommentiertes und stabiles Demo-Skript für den Kontakt-Test.
# IOB-BERECHNUNG WURDE ENTFERNT.
# ==============================================================================

using HTTP
using JSON3
using Dates
using SHA
using Logging # WICHTIG: Erlaubt strukturiertes Melden von Fehlern (@error, @warn)

# --- 1. KONFIGURATION (WICHTIG!) ---

# HINWEIS: Aktualisieren Sie IP-Adresse und Port, falls Ihr Gerät gewechselt hat.
# Dies sollte die IP-Adresse im lokalen Netzwerk sein, auf der Juggluco läuft.
const JUGGLUCO_BASE_URL = "http://192.168.178.48:17580" 

# >>>>>>>>>>>>>>>>>> HIER MUSS DER WERT GEÄNDERT WERDEN <<<<<<<<<<<<<<<<<<
# API_SECRET: Muss exakt mit dem in Juggluco konfigurierten Webserver-Schlüssel 
# übereinstimmen. Groß-/Kleinschreibung ist relevant!
const API_SECRET = "token-ottoottootto" # <--- HIER Ihren echten Schlüssel einfügen!
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Anzahl der Einträge, die abgerufen werden sollen (Glukose und Behandlungen). 
const COUNT = 20

# Das Intervall, in dem die Daten neu geladen werden (in Sekunden).
const REFRESH_INTERVAL_SECONDS = 300 # 300 Sekunden = 5 Minuten

# --- 2. EMPFOHLENE JUGGLUCO-WEBSERVER-EINSTELLUNGEN ---
# Für eine erfolgreiche Verbindung sollten in Juggluco unter Einstellungen > Webserver
# folgende Punkte gesetzt sein:
# [X] Aktiviert (On activ)
# [ ] Nur Lokales Netz (Off only local) -> Kann auf 'On' stehen, wenn PC/Skript im selben WLAN
# [ ] SSL verwenden (Off use SSL)
# [X] Mengen geben (On Mengen geben) -> Erlaubt das Senden von Behandlungsdaten

# ==============================================================================

"""
Führt einen gesicherten HTTP-GET-Request zum Juggluco-Server aus.
Verwendet SHA-1 Hashing des API_SECRET zur Authentifizierung (Nightscout-Standard).
@return: JSON3-Objekt bei Erfolg, sonst nothing.
"""
function fetch_data(endpoint::String)
    url = JUGGLUCO_BASE_URL * endpoint
    
    # 1. API Secret in SHA1-Hash umwandeln (Kompatibilität mit Nightscout-API)
    sha1_hash = bytes2hex(sha1(API_SECRET))

    # 2. Den SHA1-Hash über den 'api-secret' Header übermitteln
    headers = ["api-secret" => sha1_hash]

    @info "Lade Daten von: $url (Verwende SHA1-Hash zur Authentifizierung)"

    try
        # HTTP-GET-Anfrage mit 10 Sekunden Read-Timeout
        response = HTTP.get(url, headers=headers, readtimeout=10)

        if response.status == 200
            # Erfolgreiche Antwort: JSON-Daten lesen
            return JSON3.read(String(response.body))
        elseif response.status == 403
            # FEHLER: Falscher API-Schlüssel oder fehlende Berechtigung
            @error "AUTHENTIFIZIERUNGSFEHLER (403 Forbidden). Prüfe API_SECRET!"
            return nothing
        else
            # Unbekannter HTTP-Fehler
            @error "Fehler beim Abrufen der Daten. Status: $(response.status)"
            return nothing
        end
    catch e
        # FEHLER: Netzwerkproblem (z.B. falsche IP, Juggluco nicht aktiv, WLAN-Verbindung unterbrochen)
        @error "Verbindungsfehler (Überprüfe IP, Port und WLAN-Verbindung): $(typeof(e)) - $e"
        return nothing
    end
end


"""
Verarbeitet die abgerufenen Glukosewerte und Behandlungen, kombiniert und sortiert sie.
@return: Gesammelte und sortierte Datenliste (NamedTuples).
"""
function process_and_display_data()
    # 1. Glukosewerte (SGV) abrufen
    entries = fetch_data("/api/v1/entries.json?count=$COUNT")
    
    # 2. Behandlungen (Insulin, Carbs, Notizen) abrufen
    treatments = fetch_data("/api/v1/treatments.json?count=$COUNT")

    if isnothing(entries) && isnothing(treatments)
        println("Es konnten keine Daten abgerufen werden.")
        return [] # Rückgabe eines leeren Arrays, falls nichts vorhanden
    end
    
    all_data = []

    # Verarbeite Glukosewerte
    if !isnothing(entries)
        for entry in entries
            # Zeitstempel: 'date' ist in Millisekunden seit 1970 (Nightscout-Standard)
            ts = DateTime(1970, 1, 1) + Millisecond(entry.date)
            sgv = entry.sgv
            direction = get(entry, :direction, "N/A")
            
            push!(all_data, (ts=ts, type="Glukose", value="$sgv mg/dL", details="Trend: $direction"))
        end
    end

    # Verarbeite Behandlungen
    if !isnothing(treatments)
        for treatment in treatments
            raw_ts = get(treatment, :date, nothing)
            
            if isnothing(raw_ts)
                @warn "Ein Treatment-Eintrag enthielt keinen gültigen Zeitstempel und wurde übersprungen."
                continue
            end
            
            ts = DateTime(1970, 1, 1) + Millisecond(raw_ts)
            details = []
            
            # --- ROBUSTE FEHLERBEHANDLUNG FÜR NULL-WERTE ---
            
            # Insulin (Robust: Konvertierung zu Float64, wenn vorhanden)
            raw_insulin = get(treatment, :insulin, nothing)
            insulin_val = isnothing(raw_insulin) ? 0.0 : Float64(raw_insulin)
            
            if insulin_val > 0.0
                push!(details, "Insulin: $(insulin_val) IE")
            end
            
            # Kohlenhydrate (Carbs) (Robust: Konvertierung zu Int, wenn vorhanden)
            raw_carbs = get(treatment, :carbs, nothing)
            carbs_val = isnothing(raw_carbs) ? 0 : Int(raw_carbs)
            
            if carbs_val > 0
                push!(details, "Kohlenhydrate: $(carbs_val) g")
            end
            
            # Notizen (Einfache Text-Notiz)
            notes_val = get(treatment, :notes, "")
            if !isempty(notes_val)
                 if isempty(details)
                     push!(details, "Notiz: $(notes_val)")
                 else
                     push!(details, "Anmerkung: $(notes_val)")
                 end
            end

            if !isempty(details)
                push!(all_data, (ts=ts, type="Behandlung", value=join(details, ", "), details=""))
            else
                # Warnung, wenn ein Behandlungseintrag keine relevanten Daten enthält.
                @warn "Treatment-Eintrag ohne relevante Details (Insulin/Carbs/Notiz) übersprungen."
            end
        end
    end

    # Sortiere alle Einträge nach der Zeit (neueste zuerst)
    sort!(all_data, by = x -> x.ts, rev=true)

    # --- DATEN ALS FLIESSTEXT AUSGEBEN ---
    
    println("\n==================================================")
    println("Zusammenfassender Bericht der Juggluco-Daten (Demo)")
    println("Abgerufen von: $JUGGLUCO_BASE_URL (Letzter Abruf: $(Dates.format(now(), "dd.mm.yyyy HH:MM:ss")))")
    println("==================================================\n")

    # Prüfung, ob Daten vorhanden sind
    if isempty(all_data)
        println("Keine Daten zum Anzeigen verfügbar.")
        return all_data
    end

    for entry in all_data
        time_str = Dates.format(entry.ts, "dd.mm.yyyy HH:MM")
        
        if entry.type == "Glukose"
            # Jede Ausgabe in einer neuen Zeile für Lesbarkeit (println)
            println("Um $time_str wurde ein Glukosewert von **$(entry.value)** gemessen ($(entry.details)).")
        elseif entry.type == "Behandlung"
            # Jede Ausgabe in einer neuen Zeile für Lesbarkeit (println)
            println("Zur Zeit $time_str wurde eine Behandlung protokolliert: **$(entry.value)**.")
        end
    end
    println("\n")

    return all_data
end


"""
Startet die Hauptschleife für den zyklischen Abruf.
Implementiert eine robuste Abbruchmöglichkeit über Ctrl+C (SIGINT).
"""
function run_cyclic_fetcher()
    # Hauptschleife für die zyklische Ausführung
    @info "Starte den zyklischen Datenabruf (Intervall: $(REFRESH_INTERVAL_SECONDS) Sekunden)..."
    
    try
        while true
            # 1. Daten abrufen und anzeigen
            process_and_display_data()
            
            # 2. Warten bis zum nächsten Abruf
            @info "Nächster Abruf in $(REFRESH_INTERVAL_SECONDS) Sekunden..."
            sleep(REFRESH_INTERVAL_SECONDS) 
        end
    catch e
        # Ermöglicht einen sauberen Abbruch der Schleife durch den Benutzer (Ctrl+C)
        if isa(e, InterruptException)
            println("\n\nZyklischer Abruf beendet durch Benutzer (Ctrl+C).")
        else
            @error "Ein unerwarteter Fehler ist aufgetreten: $e"
        end
    end
end

# Führe die zyklische Funktion in einem globalen Logger-Kontext aus
with_logger(current_logger()) do
    run_cyclic_fetcher()
end
