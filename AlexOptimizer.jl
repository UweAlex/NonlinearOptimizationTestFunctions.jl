module AlexOptimizer
using LinearAlgebra, Statistics
include("SimplexModul.jl")
using .SimplexModul

# Definition der CallCounter-Struktur
mutable struct CallCounter
    f_calls::Int
    g_calls::Int
end

# Definition der Parameterstruktur
struct AlexParams
    initial_alpha::Float64
    gamma::Float64
end

# Standardparameter
function default_params()
    return AlexParams(0.01, 2.0)
end

# Wrapper für sichere Funktions- und Gradientenauswertung
function safe_loss_evaluation(loss_fn::Function, x::Vector{Float64}, counter::CallCounter, simplex::Simplex)
    # Inkrementiere f_calls für jeden Funktionsaufruf
    counter.f_calls += 1
    
    # Berechne Funktionswert und Gradient gleichzeitig
    fx, grad = loss_fn(x)
    
    # Inkrementiere g_calls, da der Gradient berechnet wurde
    counter.g_calls += 1
    
    # Hole besten und schlechtesten Punkt für Ersatzwert-Regeln
    x_best = find_best_point(simplex).x
    fx_best = find_best_point(simplex).fx
    fx_worst = find_worst_point(simplex).fx
    
    # Prüfe auf ungültigen Funktionswert
    if isnan(fx) || isinf(fx)
        fx = (fx_worst - fx_best) * 1000.0 + fx_worst
    end
    
    # Prüfe auf ungültigen Gradienten
    if any(isnan, grad) || any(isinf, grad)
        diff = x - x_best # Richtung von x_best weg
        norm_diff = norm(diff)
        norm_x_best = norm(x_best)
        if norm_diff > 1e-12 && norm_x_best > 1e-12
            grad = diff * 1000.0 * norm_x_best / norm_diff
        else
            # Fallback, wenn Normen zu klein sind, um numerische Instabilität zu vermeiden
            grad = zeros(length(x))
        end
    end
    
    return fx, grad
end

# Anpassung der Schrittweite
function adjust_stepsize(x_base::Vector{Float64}, direction::Vector{Float64}, grad_base::Vector{Float64}, loss_fn::Function, current_alpha::Float64, min_alpha::Float64, max_alpha::Float64, counter::CallCounter, gamma::Float64, fx_base::Float64, simplex::Simplex)
    x_candidate = x_base + current_alpha * direction
    fx_candidate, grad_candidate = safe_loss_evaluation(loss_fn, x_candidate, counter, simplex)
    
    psi_prime_0 = dot(grad_base, direction)
    psi_prime_alpha = dot(grad_candidate, direction)
    dAd = abs(psi_prime_alpha - psi_prime_0) > 1e-12 ? (psi_prime_alpha - psi_prime_0) / current_alpha : 1.0
    new_alpha = abs(psi_prime_alpha - psi_prime_0) > 1e-12 ? -psi_prime_0 / dAd * gamma : current_alpha * 5.0
    new_alpha = max(min_alpha, min(new_alpha, max_alpha))
    psi_alpha = fx_base + current_alpha * psi_prime_0 + 0.5 * current_alpha^2 * dAd
    if psi_alpha >= fx_base
        new_alpha = current_alpha * 0.7
    end
    return x_candidate, fx_candidate, grad_candidate, new_alpha, counter
end

# Gradientenbasierter Optimierungsschritt
function gradient_descent_step!(simplex::Simplex, loss_fn::Function, current_alpha::Float64, min_alpha::Float64, max_alpha::Float64, counter::CallCounter, iter::Int, gamma::Float64; direction=nothing)
    x_best = find_best_point(simplex)
    println("  -> Gradient Descent Step: fx=$(x_best.fx), ||x||=$(norm(x_best.x)), ||∇f||=$(norm(x_best.grad)), Simplexgröße=$(length(simplex.points))")
    
    search_direction = direction === nothing ? -x_best.grad : direction
    if norm(search_direction) < 1e-12
        println("    -> Schritt übersprungen: Nullrichtung")
        return false, nothing, current_alpha, counter, x_best
    end
    
    x_candidate, fx_candidate, grad_candidate, new_alpha, counter = adjust_stepsize(x_best.x, search_direction, x_best.grad, loss_fn, current_alpha, min_alpha, max_alpha, counter, gamma, x_best.fx, simplex)
    candidate = SimplexPoint(x_candidate, fx_candidate, grad_candidate)
    
    fx_best = find_best_point(simplex).fx
    fx_worst = find_worst_point(simplex).fx
    status = fx_candidate < fx_best ? "besser" : (fx_candidate > fx_worst ? "schlechter" : "mittel")
    println("    -> Kandidat: fx=$(fx_candidate), ||∇f||=$(norm(grad_candidate)), α=$new_alpha, Status=$status")
    
    success = norm(x_candidate - x_best.x) > 1e-10
    return success, candidate, new_alpha, counter, x_best
end

# Teilraumoptimierungsschritt
function subspace_optimization_step!(simplex::Simplex, loss_fn::Function, iter::Int, counter::CallCounter; evaluate=true)
    println("  -> Subspace Optimization Step: Simplexgröße=$(length(simplex.points))")
    if length(simplex.points) < 3
        println("    -> übersprungen: zu wenige Punkte")
        return false, nothing, nothing, nothing, counter
    end
    
    x_subspace, model_gradient, fx_model = subspace_optimization(simplex)
    if x_subspace === nothing
        println("    -> abgebrochen: subspace_optimization fehlgeschlagen")
        return false, nothing, nothing, nothing, counter
    end
    
    if !evaluate
        println("    -> Modell fx=$fx_model geschätzt (ohne Auswertung)")
        return true, x_subspace, model_gradient, fx_model, counter
    end
    
    fx_subspace, grad_subspace = safe_loss_evaluation(loss_fn, x_subspace, counter, simplex)
    candidate = SimplexPoint(x_subspace, fx_subspace, grad_subspace)
    
    fx_best = find_best_point(simplex).fx
    fx_worst = find_worst_point(simplex).fx
    status = fx_subspace < fx_best ? "besser" : (fx_subspace > fx_worst ? "schlechter" : "mittel")
    println("    -> Kandidat: fx=$(fx_subspace), ||∇f||=$(norm(grad_subspace)), Status=$status")
    
    success = fx_subspace < fx_worst
    return success, candidate, model_gradient, fx_model, counter
end

# Hybride Mischmethode
function hybrid_mixing_step!(simplex::Simplex, loss_fn::Function, current_alpha::Float64, min_alpha::Float64, max_alpha::Float64, counter::CallCounter, iter::Int, gamma::Float64)
    println("  -> Hybrid Mixing Step: Simplexgröße=$(length(simplex.points))")
    
    # Schritt 1: Teilraumoptimierung ohne Auswertung
    success, x_subspace, model_gradient, fx_model = subspace_optimization_step!(simplex, loss_fn, iter, counter; evaluate=false)
    if !(success && x_subspace !== nothing && model_gradient !== nothing)
        println("    -> fehlgeschlagen (Subspace Optimization)")
        return false, nothing, current_alpha, counter
    end
    
    # Schritt 2: Gradientenschritt vom Teilraumpunkt aus
    x_new = x_subspace - current_alpha * model_gradient
    fx_new, grad_new = safe_loss_evaluation(loss_fn, x_new, counter, simplex)
    
    # Schritt 3: Adaptive Schrittweitenberechnung
    psi_prime_0 = -dot(model_gradient, model_gradient)
    psi_prime_alpha = dot(grad_new, -model_gradient)
    dAd = abs(psi_prime_alpha - psi_prime_0) > 1e-12 ? (psi_prime_alpha - psi_prime_0) / current_alpha : 1.0
    new_alpha = abs(psi_prime_alpha - psi_prime_0) > 1e-12 ? -psi_prime_0 / dAd * gamma : current_alpha * 5.0
    new_alpha = max(min_alpha, min(new_alpha, max_alpha))
    
    # Quadratisches Modell-Check
    psi_alpha = fx_model + current_alpha * psi_prime_0 + 0.5 * current_alpha^2 * dAd
    if psi_alpha >= fx_model
        new_alpha = current_alpha * 0.7
    end
    
    candidate = SimplexPoint(x_new, fx_new, grad_new)
    fx_best = find_best_point(simplex).fx
    fx_worst = find_worst_point(simplex).fx
    status = fx_new < fx_best ? "besser" : (fx_new > fx_worst ? "schlechter" : "mittel")
    println("    -> Kandidat: fx=$(fx_new), ||∇f||=$(norm(grad_new)), α=$new_alpha, Status=$status")
    
    success = fx_new < fx_worst
    return success, candidate, new_alpha, counter
end

# Hauptoptimierungsfunktion
function optimize(loss_fn::Function, x_initial::Vector{Float64}, k_max::Int, max_iterations::Int=1000, tolerance::Float64=1e-10)
    params = default_params()
    counter = CallCounter(0, 0)
    
    # Temporärer Simplex für Initialisierung
    simplex = Simplex(x_initial, 0.0, zeros(length(x_initial)), k_max)
    fx_initial, grad_initial = safe_loss_evaluation(loss_fn, x_initial, counter, simplex)
    
    if isnan(fx_initial) || isinf(fx_initial) || any(isnan, grad_initial) || any(isinf, grad_initial)
        error("Initialer Funktionswert oder Gradient ist ungültig (NaN oder Inf)")
    end
    
    # Aktualisierter Simplex mit gültigen Werten
    simplex = Simplex(x_initial, fx_initial, grad_initial, k_max)
    optimization_history = Float64[fx_initial]
    current_alpha, min_alpha, max_alpha = params.initial_alpha, 1e-12, 1e5

    for iteration in 1:max_iterations
        println("\n=== Iteration $iteration ===")
        x_best = find_best_point(simplex)
        println("  Bester Punkt: fx=$(x_best.fx), ||x||=$(norm(x_best.x)), ||∇f||=$(norm(x_best.grad)), Simplexgröße=$(length(simplex.points))")

        # Primäre Strategie: Hybride Mischmethode
		println("Versuche hybrid_mixing_step!")
        mixing_success, mixing_candidate, new_alpha_mixing, counter = hybrid_mixing_step!(simplex, loss_fn, current_alpha, min_alpha, max_alpha, counter, iteration, params.gamma)
        current_alpha = new_alpha_mixing
        
        if mixing_success && mixing_candidate !== nothing
			println("Punkt wird in Simplex übernommen")
            add_point!(simplex, mixing_candidate)
        else
            # Fallback-Strategien
            println("  -> Fallback auf Subspace und Gradient Steps")
            
            # Teilraumoptimierung
            subspace_success, subspace_candidate, _, _, counter = subspace_optimization_step!(simplex, loss_fn, iteration, counter)
            if subspace_candidate !== nothing
                add_point!(simplex, subspace_candidate)
            end
            
            # Gradientenabstieg
            gradient_success, gradient_candidate, new_alpha_gradient, counter, x_best = gradient_descent_step!(simplex, loss_fn, current_alpha, min_alpha, max_alpha, counter, iteration, params.gamma)
            current_alpha = new_alpha_gradient
            if gradient_candidate !== nothing
                add_point!(simplex, gradient_candidate)
            end
            
            # Abbruch wenn kein Fortschritt
            if !subspace_success && !gradient_success
                println("--- Abbruch: Kein Fortschritt ---")
                break
            end
        end
        
        # Verlauf aktualisieren
        push!(optimization_history, find_best_point(simplex).fx)
        
        # Konvergenzprüfung
        if norm(find_best_point(simplex).grad) < tolerance || find_best_point(simplex).fx < tolerance
            println("--- Abbruch: Konvergenz erreicht ---")
            break
        end
    end
    
    final_point = find_best_point(simplex)
    println("\nAlex: fx=$(final_point.fx), ||x||=$(norm(final_point.x)), ||∇f||=$(norm(final_point.grad)), Funktionsaufrufe=$(counter.f_calls), Gradientenaufrufe=$(counter.g_calls)")
    
    return final_point.x, optimization_history, counter.f_calls, counter.g_calls
end

export optimize, AlexParams, default_params, CallCounter
end # module AlexOptimizer