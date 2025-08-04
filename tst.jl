# find_rana_minimum.jl
# Programm zur Optimierung des Minimums der Rana-Funktion
# x_1 = -500.0 fixiert, x_2 im Bereich [-500.0, -499.0]
# Verfahren: Intervallhalbierung mit Gradientenrichtung
# Ausgabe: Position, Funktionswert und Gradient am Minimum

using LinearAlgebra
using NonlinearOptimizationTestFunctions: rana, rana_gradient

# Definiere die eindimensionale Zielfunktion und Gradienten für x_2 (x_1 = -500.0 fixiert)
function rana_1d(x2::Float64)
    x = [-500.0, x2]
    return rana(x)
end

function rana_gradient_1d(x2::Float64)
    x = [-500.0, x2]
    grad = rana_gradient(x)
    return grad[2]  # Nur die x_2-Komponente des Gradienten
end

# Optimierung mit Intervallhalbierung und Gradienten
function find_rana_minimum()
    # Grenzen für x_2
    x2_left = -500.0
    x2_right = -499.0
    max_iterations = 10000  # Maximale Anzahl Iterationen
    tol = 1e-160  # Toleranz für Konvergenz

    iteration = 0

    while iteration < max_iterations
        # Gradienten an den Intervallgrenzen
        grad_left = rana_gradient_1d(x2_left)
        grad_right = rana_gradient_1d(x2_right)

        # Prüfe, ob das Minimum außerhalb des Intervalls liegt
        if grad_left > 0 && grad_right > 0
            println("Beide Gradienten positiv, Minimum wahrscheinlich bei x_2 = -500.0")
            min_x = [-500.0, -500.0]
            min_f = rana_1d(-500.0)
            min_grad = rana_gradient(min_x)
            return min_x, min_f, min_grad
        elseif grad_left < 0 && grad_right < 0
            println("Beide Gradienten negativ, Minimum wahrscheinlich bei x_2 = -499.0")
            min_x = [-500.0, -499.0]
            min_f = rana_1d(-499.0)
            min_grad = rana_gradient(min_x)
            return min_x, min_f, min_grad
        end

        # Mittelpunkt berechnen
        x2_mid = (x2_left + x2_right) / 2
        grad_mid = rana_gradient_1d(x2_mid)

        # Überprüfe Konvergenz
        if abs(x2_right - x2_left) < tol || abs(grad_mid) < tol
            min_x = [-500.0, x2_mid]
            min_f = rana_1d(x2_mid)
            min_grad = rana_gradient(min_x)
            println("Bestes Minimum gefunden:")
            println("Position: ", min_x)
            println("Funktionswert: ", min_f)
            println("Gradient: ", min_grad)
            return min_x, min_f, min_grad
        end

        # Entscheide, welches Intervall beibehalten wird
        if grad_mid > 0
            # Gradient zeigt nach rechts, Minimum links von x2_mid
            x2_right = x2_mid
        else
            # Gradient zeigt nach links, Minimum rechts von x2_mid
            x2_left = x2_mid
        end

        iteration += 1
    end

    # Falls keine Konvergenz, wähle den besten Punkt
    x2_mid = (x2_left + x2_right) / 2
    min_x = [-500.0, x2_mid]
    min_f = rana_1d(x2_mid)
    min_grad = rana_gradient(min_x)
    println("Maximale Iterationen erreicht. Bestes Minimum:")
    println("Position: ", min_x)
    println("Funktionswert: ", min_f)
    println("Gradient: ", min_grad)
    return min_x, min_f, min_grad
end

# Führe die Optimierung aus
min_x, min_f, min_grad = find_rana_minimum()