# src/l1_penalty_wrapper.jl

# Der echte Wrap-Cloner – dein Meisterwerk

const BOUND_PENALTY = 1e18

function with_box_constraints(tf::TestFunction)
    if !bounded(tf)
        return tf
    end

    n = dim(tf) == -1 ? DEFAULT_N[] : dim(tf)
    lb_vec = lb(tf, n)
    ub_vec = ub(tf, n)
    x_buffer = Vector{Float64}(undef, n)

    f_wrap = let x_buffer=x_buffer, lb_vec=lb_vec, ub_vec=ub_vec, tf=tf
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

    grad_wrap! = let x_buffer=x_buffer, lb_vec=lb_vec, ub_vec=ub_vec, tf=tf
        function (g::AbstractVector{T}, x::AbstractVector{T}) where T
            any(isnan, x) && (fill!(g, T(NaN)); return)
            any(isinf, x) && (fill!(g, T(Inf)); return)

            @inbounds @simd for i in eachindex(x)
                x_buffer[i] = clamp(x[i], lb_vec[i], ub_vec[i])
            end

            tf.gradient!(g, x_buffer)  # ← hier war der Fehler!

            @inbounds @simd for i in eachindex(g, x)
                if x[i] < lb_vec[i]
                    g[i] = -T(BOUND_PENALTY)
                elseif x[i] > ub_vec[i]
                    g[i] =  T(BOUND_PENALTY)
                end
            end
        end
    end

    new_meta = deepcopy(tf.meta)
    new_meta[:name] = string(tf.meta[:name], "_constrained")
    new_meta[:description] *= " (hard box constraints via L1 exact penalty – wrap-clone)"

    # ──────── DER WRAP-CLONER: Neues TestFunction! ────────
    return TestFunction(
        f_wrap,
        x -> (g = similar(x); grad_wrap!(g, x); g),  # out-of-place grad
        new_meta
    )
end

export with_box_constraints