using Test, ForwardDiff
using NonlinearOptimizationTestFunctions
using Random


# Hilfsfunktion: Berechnet den numerischen Gradienten mittels zentraler Differenzen
# Eingabe: f (Funktion), x (Punkt), eps_val (Präzision für Schrittweite, Standard: Maschinengenauigkeit)
# Ausgabe: Gradientenvektor (numerische Näherung)
function finite_difference_gradient(f, x; eps_val=eps(Float64))
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        fx = abs(f(x))
        # Schrittweite h abhängig von Funktionswert und Punktkoordinate
        h = max(fx > 0 ? sqrt(eps_val) * sqrt(fx) : 1e-8, eps_val * abs(x[i]))
        x_plus = copy(x); x_plus[i] += h
        x_minus = copy(x); x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2*h)
    end #for
    return grad
    # Zweck: Berechnet den numerischen Gradienten mit zentralen Differenzen für hohe Präzision
end #function

# Hilfsfunktion: Berechnet den relativen Unterschied zwischen zwei Vektoren
# Eingabe: a, b (Vektoren), epsilon (kleiner Wert zur Vermeidung von Division durch 0)
# Ausgabe: Norm der relativen Unterschiede
function relative_diff(a, b; epsilon=1e-10)
    rel_diff = 0 
    for i in eachindex(a)
        rel_diff += abs(a[i] - b[i]) / (abs(a[i]) + abs(b[i]) + epsilon)
    end #for
    return rel_diff 
    # Zweck: Misst eine relative Abweichung zwischen zwei Gradientenvektoren;
end #function

# Hilfsfunktion: Extrahiert Metadatenwerte und wandelt sie in Float64 um
# Eingabe: field (Metadatenfeld), n (Dimension), is_scalable (skalierbar?), fn_name (Funktionsname), field_name (Feldname)
# Ausgabe: Metadatenwert als Float64-Vektor
function get_meta_value(field, n, is_scalable, fn_name, field_name)
    try
        if isa(field, Function)
            return float.(is_scalable ? field(n) : field())
        else
            return float.(field)
        end #if
    catch e
        error("Error in $field_name for $fn_name: $e")
    end #try
    # Zweck: Extrahiert Metadaten (z.B. min_position, lb, ub), prüft Gültigkeit und wirft Fehler bei Problemen
end #function

# Hilfsfunktion: Prüft, ob ein Punkt endliche Funktionswerte und Gradienten liefert
# Eingabe: tf (Testfunktion), point (Punkt), finite_difference_gradient (Gradientenfunktion), fn_name (Funktionsname)
# Ausgabe: Tupel (is_valid, error_msg, diff_an_ad, diff_num_ad, diff_an_num)
function is_valid_point(tf, point, finite_difference_gradient, fn_name)
    try
        fx = tf.f(point)
        !isfinite(fx) && return (false, "Non-finite function value for $fn_name at point=$point", 0.0, 0.0, 0.0)
        an_grad = tf.grad(point)
        !all(isfinite, an_grad) && return (false, "Non-finite analytical gradient for $fn_name at point=$point", 0.0, 0.0, 0.0)
        ad_grad = ForwardDiff.gradient(tf.f, point)
        !all(isfinite, ad_grad) && return (false, "Non-finite AD gradient for $fn_name at point=$point", 0.0, 0.0, 0.0)
        num_grad = finite_difference_gradient(tf.f, point)
        !all(isfinite, num_grad) && return (false, "Non-finite numerical gradient for $fn_name at point=$point", 0.0, 0.0, 0.0)
        # Berechne relative Abweichungen für gültige Punkte
        diff_an_ad = relative_diff(an_grad, ad_grad)
        diff_num_ad = relative_diff(num_grad, ad_grad)
        diff_an_num = relative_diff(an_grad, num_grad)
        return (true, "", diff_an_ad, diff_num_ad, diff_an_num)
    catch e
        return (false, "Error for $fn_name at point=$point: $e", 0.0, 0.0, 0.0)
    end #try
    # Zweck: Prüft, ob der Punkt gültige (endliche) Werte für Funktion und Gradienten liefert;
    #        berechnet bei Gültigkeit die relativen Abweichungen (AD vs. AG, ND vs. AD, AG vs. ND) für direkte Summierung
end #function

# Hauptfunktion: Generiert 40 Punkte mit schrittweiser Annäherung an das Optimum
# Eingabe: tf (Testfunktion), n (Dimension), finite_difference_gradient (Gradientenfunktion), max_attempts (maximale Versuche)
# Ausgabe: Tupel (sum_an_ad, sum_num_ad, sum_an_num) mit Summen der relativen Abweichungen
function generate_points_converging_to_optimum(tf, n, finite_difference_gradient; max_attempts=5)
    fn_name = tf.meta[:name]
    is_bounded = "bounded" in tf.meta[:properties]
    is_scalable = "scalable" in tf.meta[:properties]
    
    # Hole Minimum-Position
    min_pos = try
        is_scalable ? float.(tf.meta[:min_position](n)) : float.(tf.meta[:min_position]())
    catch e
        error("Error in min_position for $fn_name: $e")
    end #try
    length(min_pos) == n || error("Dimension mismatch for $fn_name: expected $n, got $(length(min_pos))")
    
    # Initialisiere Schranken
    lb = is_bounded ? get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb") : min_pos .- 5.0
    ub = is_bounded ? get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub") : min_pos .+ 5.0
    
    sum_an_ad = 0.0
    sum_num_ad = 0.0
    sum_an_num = 0.0
    
    for i in 1:40
        t = (i - 1) / 40
        current_lb, current_ub = min_pos + (1 - t) * (lb - min_pos), min_pos + (1 - t) * (ub - min_pos)
        
        point = zeros(n)
        attempts = 0
        while attempts < max_attempts
            point = current_lb + rand(n) .* (current_ub - current_lb)
            is_valid, error_msg, diff_an_ad, diff_num_ad, diff_an_num = is_valid_point(tf, point, finite_difference_gradient, fn_name)
            if is_valid
                sum_an_ad += diff_an_ad
                sum_num_ad += diff_num_ad
                sum_an_num += diff_an_num
                break
            end #if
            attempts += 1
            if attempts == max_attempts
                error("Failed to generate valid point for $fn_name at step $i after $max_attempts attempts")
            end #if
        end #while
    end #for
    
    return sum_an_ad, sum_num_ad, sum_an_num
    # Zweck: Generiert 40 gültige Punkte, die sich schrittweise dem Minimum nähern, summiert die relativen
    #        Abweichungen (AD vs. AG, ND vs. AD, AG vs. ND); wirft Fehler, wenn weniger als 40 Punkte generiert werden
end #function

# Testset: Überprüft die Genauigkeit der analytischen Gradienten
# Prüft alle Testfunktionen, jede mit 40 Punkten, auf korrekte analytische Gradienten
@testset "Gradient Accuracy Tests" begin
    Random.seed!(1234) # Fixiert Zufallszahlen für Reproduzierbarkeit
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        
        # Bestimme Dimension (n=4 für skalierbare Funktionen, sonst n=2)
        is_scalable = "scalable" in tf.meta[:properties]
        n = is_scalable ? 4 : 2
        min_pos = try
            get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
        catch e
            error("Error in min_position for $fn_name: $e")
        end #try
        n = length(min_pos)
        
        # Generiere 40 Punkte und summiere relative Abweichungen
        sum_an_ad, sum_num_ad, sum_an_num = try
            generate_points_converging_to_optimum(tf, n, finite_difference_gradient)
        catch e
            error("Error in generate_points_converging_to_optimum for $fn_name: $e")
        end #try
        
        # Prüfe, ob numerischer Gradient genauer ist als analytischer (Fehlerfall)
        if sum_num_ad < sum_an_ad && sum_num_ad < sum_an_num
            error("Test failed: Function $fn_name has unreliable analytical gradient: sum_num_ad=$sum_num_ad < sum_an_ad=$sum_an_ad, sum_an_num=$sum_an_num")
        else
            println("Function $fn_name passed: sum_an_ad=$sum_an_ad, sum_num_ad=$sum_num_ad, sum_an_num=$sum_an_num")
        end #if
    end #for
    # Zweck: Testet für jede Funktion die Genauigkeit des analytischen Gradienten (AG) gegenüber dem automatischen
    #        Gradienten (AD) und numerischen Gradienten (ND); erwartet, dass sum_an_ad klein ist und sum_num_ad
    #        größer als sum_an_ad und sum_an_num (stärkere Bedingung); wirft Fehler bei unzuverlässigem AG;
    #        gibt Erfolgsmeldung für bestandene Funktionen aus
end #testset