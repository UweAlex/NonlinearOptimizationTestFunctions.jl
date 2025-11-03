# ==============================================================================
# Juggluco Datenabruf-Programm in Julia (Zyklische Version)
# Diese Version enthält eine robuste Fehlerbehandlung für 'null'-Werte in JSON.
# ==============================================================================

using HTTP
using JSON3
using Dates
using SHA

# --- KONFIGURATION (WICHTIG!) ---

# HINWEIS: Aktualisiert auf die IP 192.168.178.48 und den Port 17580.
const JUGGLUCO_BASE_URL = "http://192.168.178.48:17580" 

# >>>>>>>>>>>>>>>>>> HIER MUSS DER WERT GEÄNDERT WERDEN <<<<<<<<<<<<<<<<<<
# BITTE PRÜFEN SIE GROSS/KLEINSCHREIBUNG UND TIPPFEHLER:
# Ersetzen Sie diesen Platzhalter DURCH IHREN EXAKTEN SCHLÜSSEL
# WICHTIG: Verwenden Sie einen Schlüssel mit MINDESTENS 12 Zeichen.
const API_SECRET = "token-ottoottootto" # <--- HIER Ihren echten Schlüssel einfügen!
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Anzahl der Einträge, die abgerufen werden sollen
const COUNT = 20

# Das Intervall, in dem die Daten neu geladen werden (in Sekunden).
# 60 Sekunden
const REFRESH_INTERVAL_SECONDS = 300 

# ==============================================================================

"""
Führt einen gesicherten HTTP-GET-Request zum Juggluco-Server aus.
"""
function fetch_data(endpoint::String)
    url = JUGGLUCO_BASE_URL * endpoint
    
    # 1. API Secret in SHA1-Hash umwandeln
    sha1_hash = bytes2hex(sha1(API_SECRET))

    # 2. Den SHA1-Hash über den 'api-secret' Header übermitteln
    headers = ["api-secret" => sha1_hash]

    println("Lade Daten von: $url (Verwende SHA1-Hash zur Authentifizierung)")

    try
        response = HTTP.get(url, headers=headers, readtimeout=10)

        if response.status == 200
            return JSON3.read(String(response.body))
        elseif response.status == 403
            println(stderr, "AUTHENTIFIZIERUNGSFEHLER (403 Forbidden).")
            println(stderr, "-> Der in JUGGLUCO konfigurierte API_SECRET stimmt NICHT mit dem im Julia-Skript überein.")
            return nothing
        else
            println(stderr, "Fehler beim Abrufen der Daten. Status: $(response.status)")
            return nothing
        end
    catch e
        println(stderr, "Verbindungsfehler (Überprüfe IP, Port, API_SECRET und WLAN-Verbindung): $e")
        return nothing
    end
end

"""
Verarbeitet die abgerufenen Glukosewerte und Behandlungen.
"""
function process_and_display_data()
    # 1. Glukosewerte (SGV = Sensor Glucose Value) abrufen
    entries = fetch_data("/api/v1/entries.json?count=$COUNT")
    
    # 2. Behandlungen (Insulin, Carbs) abrufen
    treatments = fetch_data("/api/v1/treatments.json?count=$COUNT")

    if isnothing(entries) && isnothing(treatments)
        println("Es konnten keine Daten abgerufen werden.")
        return
    end

    all_data = []

    # Verarbeite Glukosewerte
    if !isnothing(entries)
        for entry in entries
            # Nutze den "date" Timestamp (Millisekunden seit Epoch)
            ts = DateTime(1970, 1, 1) + Millisecond(entry.date)
            sgv = entry.sgv
            direction = get(entry, :direction, "N/A")
            
            # Füge SGV-Einträge zur gemeinsamen Liste hinzu
            push!(all_data, (ts=ts, type="Glukose", value="$sgv mg/dL", details="Trend: $direction"))
        end
    end

    # Verarbeite Behandlungen
    if !isnothing(treatments)
        for treatment in treatments
            # Timestamp für Treatments: Nutzen Sie "date", wie in den Rohdaten bestätigt.
            raw_ts = get(treatment, :date, nothing)
            
            if isnothing(raw_ts)
                println(stderr, "Warnung: Ein Treatment-Eintrag enthielt keinen gültigen Zeitstempel und wurde übersprungen.")
                continue
            end
            
            # Konvertiere den gefundenen Millisekunden-Timestamp
            ts = DateTime(1970, 1, 1) + Millisecond(raw_ts)
            
            details = []
            
            # --- ROBUSTE FEHLERBEHANDLUNG FÜR NULL-WERTE ---

            # Insulin (erwartet Float64)
            raw_insulin = get(treatment, :insulin, nothing)
            # Setze auf 0.0, falls der Wert 'nothing' (JSON null oder fehlend) ist
            insulin_val = isnothing(raw_insulin) ? 0.0 : Float64(raw_insulin)
            
            if insulin_val > 0.0
                push!(details, "Insulin: $(insulin_val) IE")
            end
            
            # Kohlenhydrate (Carbs) (erwartet Int64)
            raw_carbs = get(treatment, :carbs, nothing)
            # Setze auf 0, falls der Wert 'nothing' (JSON null oder fehlend) ist
            carbs_val = isnothing(raw_carbs) ? 0 : Int(raw_carbs)
            
            if carbs_val > 0
                push!(details, "Kohlenhydrate: $(carbs_val) g")
            end
            
            # --- Ende Fehlerbehandlung ---

            # Notizen (Notes)
            notes_val = get(treatment, :notes, "")
            if !isempty(notes_val)
                 if isempty(details)
                     push!(details, "Notiz: $(notes_val)")
                 else
                     push!(details, "Anmerkung: $(notes_val)")
                 end
            end

            if !isempty(details)
                # Füge Behandlungs-Einträge zur gemeinsamen Liste hinzu
                push!(all_data, (ts=ts, type="Behandlung", value=join(details, ", "), details=""))
            end
        end
    end

    # Sortiere alle Einträge nach der Zeit (neueste zuerst)
    sort!(all_data, by = x -> x.ts, rev=true)

    # --- DATEN ALS FLIESSTEXT AUSGEBEN ---
    
    println("\n==================================================")
    println("Zusammenfassender Bericht der Juggluco-Daten")
    println("Abgerufen von: $JUGGLUCO_BASE_URL (Letzter Abruf: $(Dates.format(now(), "HH:MM:ss")))")
    println("==================================================\n")

    for entry in all_data
        time_str = Dates.format(entry.ts, "dd.mm.yyyy HH:MM")
        
        # Fließtext-Formatierung
        if entry.type == "Glukose"
            print("Um $time_str wurde ein Glukosewert von **$(entry.value)** gemessen ($(entry.details)). ")
        elseif entry.type == "Behandlung"
            print("Zur Zeit $time_str wurde eine Behandlung protokolliert: **$(entry.value)**. ")
        end
    end
    println("\n") # Leerzeile nach dem Bericht
end


"""
Startet die Hauptschleife für den zyklischen Abruf.
"""
function run_cyclic_fetcher()
    # Hauptschleife für die zyklische Ausführung
    println("Starte den zyklischen Datenabruf (Intervall: $(REFRESH_INTERVAL_SECONDS) Sekunden)...")
    
    while true
        # 1. Daten abrufen und anzeigen
        process_and_display_data()
        
        # 2. Warten bis zum nächsten Abruf
        println("Nächster Abruf in $(REFRESH_INTERVAL_SECONDS) Sekunden...")
        sleep(REFRESH_INTERVAL_SECONDS) 
    end
end

# Führe die zyklische Funktion aus
run_cyclic_fetcher()
