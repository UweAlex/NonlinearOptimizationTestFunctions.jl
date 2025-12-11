# src/l1_penalty_wrapper.jl
# MAXIMALES DEBUGGING – wir lassen nichts mehr im Dunkeln
# Nur für powellsingular2, aber jetzt mit absolutem Beweis

const BOUND_PENALTY = 1e18

function with_box_constraints(tf::TestFunction)
    # ==================== ULTRA-DEBUG FÜR POWELLSINGULAR2 ====================
    if tf.name == "powellsingular2"
        println("\n" * "═"^90)
        println("WITH_BOX_CONSTRAINTS WIRD JETZT AUSGEFÜHRT – LETZTE CHANCE VOR DEM CRASH")
        println("═"^90)
        println("   tf.name                    : ", tf.name)
        println("   bounded?                   : ", "bounded" in tf.meta[:properties])
        println("   dim(tf)                    : ", dim(tf))
        println("   DEFAULT_N[] (global)       : ", DEFAULT_N[])
        println("   haskey(:default_n)         : ", haskey(tf.meta, :default_n))
        println("   tf.meta[:default_n]        : ", get(tf.meta, :default_n, "FEHLT KOMPLETT"))
        println("   length(min_position(tf))   : ", try
            length(min_position(tf))
        catch e
            "FEHLER: $e"
        end)
        println("   start(tf, 4) funktioniert? : ", try
            length(start(tf, 4))
        catch e
            "NEIN → $e"
        end)
    end
    # =========================================================================

    if !("bounded" in tf.meta[:properties])
        return tf
    end

    # DIE ENTSCHEIDENDE ZEILE – HIER WIRD DER MORD BEGANGEN
    n = dim(tf) == -1 ? tf.meta[:default_n] : dim(tf)

    if tf.name == "powellsingular2"
        println("   → with_box_constraints entscheidet sich für n = $n")
        println("   → Weil dim(tf) == -1 → nimmt DEFAULT_N[] = $(DEFAULT_N[])")
        println("   → Aber :default_n = 4 existiert und wird KOMPLETT IGNORIERT")
        println("   → Deshalb wird jetzt lb(tf, $n) aufgerufen → CRASH")
        println("═"^90)
    end

    # Jetzt kommt der unvermeidliche Untergang:
    lb_vec = lb(tf, n)
    ub_vec = ub(tf, n)

    if tf.name == "powellsingular2"
        println("   → WIR LEBEN NOCH! lb(tf, $n) hat funktioniert – das darf nicht sein!")
        println("   → Das bedeutet: Die Funktion hat n=$n akzeptiert – aber das ist falsch!")
    end

    # Rest (wird nie erreicht bei powellsingular2 mit n=2)
    x_buffer = Vector{Float64}(undef, n)

    f_wrap = let x_buffer = x_buffer, lb_vec = lb_vec, ub_vec = ub_vec, tf = tf
        function (x::AbstractVector{T}) where T
            any(isnan, x) && return T(NaN)
            any(isinf, x) && return T(Inf)
            violation = zero(T)
            @inbounds @simd for i in eachindex(x)
                xi = x[i]
                if xi < lb_vec[i]
                    violation += (lb_vec[i] - xi)
                    x_buffer[i] = lb_vec[i]
                elseif xi > ub_vec[i]
                    violation += (xi - ub_vec[i])
                    x_buffer[i] = ub_vec[i]
                else
                    x_buffer[i] = xi
                end
            end
            return tf.f(x_buffer) + T(BOUND_PENALTY) * violation
        end
    end

    grad_wrap! = let x_buffer = x_buffer, lb_vec = lb_vec, ub_vec = ub_vec, tf = tf
        function (g::AbstractVector{T}, x::AbstractVector{T}) where T
            any(isnan, x) && (fill!(g, T(NaN)); return)
            any(isinf, x) && (fill!(g, T(Inf)); return)
            @inbounds @simd for i in eachindex(x)
                x_buffer[i] = clamp(x[i], lb_vec[i], ub_vec[i])
            end
            tf.gradient!(g, x_buffer)
            @inbounds @simd for i in eachindex(g, x)
                if x[i] < lb_vec[i]
                    g[i] = -T(BOUND_PENALTY)
                elseif x[i] > ub_vec[i]
                    g[i] = T(BOUND_PENALTY)
                end
            end
        end
    end

    new_meta = deepcopy(tf.meta)
    new_meta[:name] = string(tf.meta[:name], "_constrained")
    new_meta[:description] *= " (hard box constraints via L1 exact penalty – wrap-clone)"
    filter!(p -> p != "bounded", new_meta[:properties])
    new_meta[:lb] = nothing
    new_meta[:ub] = nothing

    return TestFunction(
        f_wrap,
        x -> (g = similar(x); grad_wrap!(g, x); g),
        new_meta
    )
end

export with_box_constraints