#Simplexmodul.jl

module SimplexModul
using LinearAlgebra, Logging

mutable struct SimplexPoint
    x::Vector{Float64}
    fx::Float64
    grad::Vector{Float64}
end

mutable struct Simplex
    points::Vector{SimplexPoint}
    k_max::Int
end

function Simplex(x0::Vector{Float64}, fx0::Float64, grad0::Vector{Float64}, k_max::Int)
    if isnan(fx0) || isinf(fx0)
        error("Initialer Funktionswert ist ungültig: fx0=$fx0")
    end
    if any(isnan, x0) || any(isinf, x0)
        error("Initiale Koordinaten sind ungültig: x0=$x0")
    end
    if any(isnan, grad0) || any(isinf, grad0)
        error("Initialer Gradient ist ungültig: grad0=$grad0")
    end
    initial_point = SimplexPoint(x0, fx0, grad0)
    return Simplex([initial_point], k_max)
end

function find_best_point(simplex::Simplex)
    valid_points = [p for p in simplex.points if !(isnan(p.fx) || isinf(p.fx))]
    if isempty(valid_points)
        @error "Kein gültiger Punkt im Simplex für find_best_point: Simplexgröße=$(length(simplex.points))"
        error("Kein gültiger Punkt im Simplex")
    end
    return valid_points[argmin([p.fx for p in valid_points])]
end

function find_worst_point(simplex::Simplex)
    valid_points = [p for p in simplex.points if !(isnan(p.fx) || isinf(p.fx))]
    if isempty(valid_points)
        @error "Kein gültiger Punkt im Simplex für find_worst_point: Simplexgröße=$(length(simplex.points))"
        error("Kein gültiger Punkt im Simplex")
    end
    return valid_points[argmax([p.fx for p in valid_points])]
end

function _calculate_a_ext_cond(points::Vector{SimplexPoint})
    k = length(points)
    if k < 2
        return Inf
    end
    valid_points = [p for p in points if !(isnan(p.fx) || isinf(p.fx) || any(isnan, p.grad) || any(isinf, p.grad))]
    if length(valid_points) < 2
        return Inf
    end
    grads = [p.grad for p in valid_points]
    G = hcat(grads...)
    A = G' * G
    A_ext = [A ones(k); ones(1, k) 0.0]
    return cond(A_ext)  # Korrigierter Fehler: Verwende A_ext statt A für Konditionszahl
end


function select_point_to_remove(simplex::Simplex, num_protected_best::Int=1)
	println("-------------------------------Wähle Punkt-------------------")
    points = simplex.points
    if length(points) <= num_protected_best
        @debug "Zu wenige Punkte zum Entfernen: Simplexgröße=$(length(points))"
        return length(points)
    end
    if length(points) >= 3
        @debug "Versuche optimale Punktentfernung für bessere Konditionierung"
        best_cond_num = Inf
        idx_to_remove = -1
        for j in (num_protected_best + 1):length(points)
            temp_points = SimplexPoint[p for (idx, p) in enumerate(points) if idx != j]
            if length(temp_points) >= 2
                current_cond = _calculate_a_ext_cond(temp_points)
                if current_cond < best_cond_num
                    best_cond_num = current_cond
                    idx_to_remove = j
                end
            end
        end
        if idx_to_remove != -1
            println("Punkt an Index >> $idx_to_remove << ausgewählt: Neue Konditionszahl=$best_cond_num")
            return idx_to_remove
        else
            @warn "Optimale Punktentfernung nicht gefunden; schlechtester Punkt (Index $(length(points))) ausgewählt"
            return length(points)
        end
    else
        @debug "Zu wenige Punkte für Konditionierungsprüfung; schlechtester Punkt (Index $(length(points))) ausgewählt"
        return length(points)
    end
end

function add_point!(simplex::Simplex, new_point::SimplexPoint)
    if isnan(new_point.fx) || isinf(new_point.fx)
        @error "Versuch, Punkt mit ungültigem Funktionswert hinzuzufügen: fx=$(new_point.fx), ||x||=$(norm(new_point.x)), Aufrufstack: $(stacktrace())"
        return false
    end
    if any(isnan, new_point.x) || any(isinf, new_point.x)
        @error "Ungültige Koordinaten im Punkt: x=$(new_point.x), Aufrufstack: $(stacktrace())"
        return false
    end
    if any(isnan, new_point.grad) || any(isinf, new_point.grad)
        @error "Ungültiger Gradient im Punkt: ||grad||=$(norm(new_point.grad)), Aufrufstack: $(stacktrace())"
        return false
    end
    @debug "Punkt wird hinzugefügt: fx=$(new_point.fx), ||x||=$(norm(new_point.x))"
    num_protected_best = 1
    push!(simplex.points, new_point)
    sort!(simplex.points, by = p -> isnan(p.fx) || isinf(p.fx) ? Inf : p.fx) # NaN/Inf ans Ende
    if length(simplex.points) > simplex.k_max + 1
        current_simplex_cond = _calculate_a_ext_cond(simplex.points)
        @debug "Konditionszahl des Simplex: $(round(current_simplex_cond, digits=2))"
        idx_to_remove = select_point_to_remove(simplex, num_protected_best)
        @debug "Punkt an Index $idx_to_remove entfernt"
        splice!(simplex.points, idx_to_remove)
    end
    return true
end

function subspace_optimization(simplex::Simplex; tol=1e-12, fx_model_tol=1e-6)
    MAX_DISTANCE_FACTOR = 10.0  # Konstante für maximale Distanz, anpassbar

    if length(simplex.points) < 2
        @warn "Teilraumoptimierung abgebrochen: Weniger als 2 Punkte im Simplex"
        return nothing, nothing, nothing
    end

    x_best = find_best_point(simplex).x
    fx_best = find_best_point(simplex).fx
    grad_best = find_best_point(simplex).grad
    k = length(simplex.points)
    n = length(simplex.points[1].x)
    x_points = [p.x for p in simplex.points]
    grads = [p.grad for p in simplex.points]

    G = hcat(grads...)
    A = G' * G
    A_ext = [A ones(k); ones(1, k) 0.0]
    b_ext = [zeros(k); 1.0]

    # Protokolliere Konditionszahl
    cond_A_ext = cond(A_ext)
    @debug "Konditionszahl von A_ext: $cond_A_ext"
    if cond_A_ext > 1e15
        @warn "Hohe Konditionszahl erkannt: $cond_A_ext"
    end

    # Berechnung von β
    β = nothing
    try
        solution = A_ext \ b_ext
        β = solution[1:k]
        sum_beta = sum(β)
        if abs(sum_beta) <= tol || any(isnan, β) || any(isinf, β) || any(abs.(β) .> 1e50)
            @warn "Teilraumoptimierung: Ungültige β-Werte (Summe=$sum_beta, min=$(minimum(β)), max=$(maximum(β))). Entferne Punkt."
            idx_to_remove = select_point_to_remove(simplex, 2)
            splice!(simplex.points, idx_to_remove)
            return nothing, nothing, nothing
        end
        β = β ./ sum_beta
    catch e
        @warn "Teilraumoptimierung: Numerische Instabilität (z. B. Singularität): $e. Entferne Punkt."
        idx_to_remove = select_point_to_remove(simplex, 2)
        splice!(simplex.points, idx_to_remove)
        return nothing, nothing, nothing
    end

    # Berechnung von x_candidate
    x_candidate = zeros(n)
    for i in 1:k
        x_candidate += β[i] * x_points[i]
    end
    if any(isnan, x_candidate) || any(isinf, x_candidate)
        @error "Ungültiger Kandidatenpunkt: x_candidate=$x_candidate. Entferne Punkt."
        idx_to_remove = select_point_to_remove(simplex, 2)
        splice!(simplex.points, idx_to_remove)
        return nothing, nothing, nothing
    end

    # Berechnung von model_gradient
    model_gradient = zeros(n)
    for i in 1:k
        model_gradient += β[i] * grads[i]
    end
    if any(isnan, model_gradient) || any(isinf, model_gradient)
        @error "Ungültiger Modell-Gradient: model_gradient=$model_gradient. Entferne Punkt."
        idx_to_remove = select_point_to_remove(simplex, 2)
        splice!(simplex.points, idx_to_remove)
        return nothing, nothing, nothing
    end

    # Berechnung von fx_model
    term1 = grad_best' * (x_candidate - x_best)
    term2 = model_gradient' * (x_candidate - x_best)
    fx_model = fx_best + 0.5 * (term1 + term2)
    if isnan(fx_model) || isinf(fx_model)
        @error "Ungültiger Modell-Funktionswert: fx_model=$fx_model. Entferne Punkt."
        idx_to_remove = select_point_to_remove(simplex, 2)
        splice!(simplex.points, idx_to_remove)
        return nothing, nothing, nothing
    end

    # Prüfe auf Entgleisung
    if fx_model > fx_best + fx_model_tol
        @warn "Teilraumoptimierung: fx_model=$fx_model ist zu groß (fx_best=$fx_best). Entferne Punkt."
        idx_to_remove = select_point_to_remove(simplex, 2)
        splice!(simplex.points, idx_to_remove)
        return nothing, nothing, nothing
    end

    # Distanzprüfung und Skalierung
    max_dist = maximum([norm(x_points[i] - x_points[1]) for i in 2:k])
    if norm(x_candidate - x_best) > MAX_DISTANCE_FACTOR * max_dist
        @debug "Kandidatenpunkt zu weit entfernt: Skaliere auf $(MAX_DISTANCE_FACTOR) * max_dist"
        v = x_candidate - x_best
        dist = norm(v)
        scaling_factor = (MAX_DISTANCE_FACTOR * max_dist) / dist
        x_candidate = x_best + scaling_factor * v
        term1 = grad_best' * (x_candidate - x_best)
        term2 = model_gradient' * (x_candidate - x_best)
        fx_model = fx_best + 0.5 * (term1 + term2)
    end

    @debug "subspace_optimization erfolgreich: fx_model=$fx_model, ||x_candidate||=$(norm(x_candidate))"
    return x_candidate, model_gradient, fx_model
end

export Simplex, SimplexPoint, add_point!, find_best_point, find_worst_point, subspace_optimization, select_point_to_remove
end # SimplexModul