# src/l1_penalty_wrapper.jl
# Hard box-constraints via L1 exact penalty – allocation-free, domain-safe
# Stand: Dezember 2025 – final version

const BOUND_PENALTY = 1e18

function with_box_constraints(tf::TestFunction)
    # Nicht bounded → unverändert zurückgeben
    "bounded" ∉ tf.meta[:properties] && return tf

    # ────── Skalierbar? → automatisch auf :default_n fixieren ──────
    tf_fixed = fixed(tf)                     # ← das ist alles, was wir brauchen!

    n = dim(tf_fixed)                        # jetzt garantiert ≠ -1
    lb_vec = tf_fixed.meta[:lb]()
    ub_vec = tf_fixed.meta[:ub]()

    # Pre-allozierter Projektions-Buffer (wird wiederverwendet → kein GC)
    x_buffer = Vector{Float64}(undef, n)

    # ────── Objective mit L1-Penalty ──────
    f_wrap = let x_buffer = x_buffer, lb_vec = lb_vec, ub_vec = ub_vec, tf = tf_fixed
        function (x::AbstractVector{T}) where T
            any(isnan, x) && return T(NaN)
            any(isinf, x) && return T(Inf)

            violation = zero(T)
            @inbounds @simd for i in eachindex(x)
                xi = x[i]
                if xi < lb_vec[i]
                    violation += lb_vec[i] - xi
                    x_buffer[i] = lb_vec[i]
                elseif xi > ub_vec[i]
                    violation += xi - ub_vec[i]
                    x_buffer[i] = ub_vec[i]
                else
                    x_buffer[i] = xi
                end
            end
            return tf.f(x_buffer) + T(BOUND_PENALTY) * violation
        end
    end

    # ────── In-place Gradient (Subgradient der exakten Penalty) ──────
    grad_wrap! = let x_buffer = x_buffer, lb_vec = lb_vec, ub_vec = ub_vec, tf = tf_fixed
        function (g::AbstractVector{T}, x::AbstractVector{T}) where T
            any(isnan, x) && (fill!(g, T(NaN)); return)
            any(isinf, x) && (fill!(g, T(Inf)); return)

            # Projektion
            @inbounds @simd for i in eachindex(x)
                x_buffer[i] = clamp(x[i], lb_vec[i], ub_vec[i])
            end

            # Original-Gradient an der projizierten Stelle
            tf.gradient!(g, x_buffer)

            # Straffunktion für Verletzungen
            @inbounds @simd for i in eachindex(g, x)
                if x[i] < lb_vec[i]
                    g[i] = -T(BOUND_PENALTY)
                elseif x[i] > ub_vec[i]
                    g[i] = T(BOUND_PENALTY)
                end
            end
        end
    end

    # ────── Neues Meta-Dictionary (bounded-Flag entfernen) ──────
    new_meta = deepcopy(tf_fixed.meta)
    new_meta[:name] = string(tf_fixed.meta[:name], "_constrained")
    new_meta[:description] *= " (hard box constraints via L1 exact penalty)"
    filter!(p -> p ≠ "bounded", new_meta[:properties])
    new_meta[:lb] = new_meta[:ub] = nothing   # keine Bounds mehr am Wrapper

    return TestFunction(
        f_wrap,
        x -> (g = similar(x); grad_wrap!(g, x); g),
        new_meta
    )
end

export with_box_constraints