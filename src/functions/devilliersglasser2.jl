# src/functions/devilliersglasser2.jl
# Purpose: Implementation of the De Villiers-Glasser 2 test function.
# Context: Non-scalable, 5-dimensional nonlinear least squares problem.
# Global minimum: f(x*)=0 at x*=[53.81, 1.27, 3.012, 2.13, 0.507]
# Bounds: 1.0 ≤ x_i ≤ 60.0 (standard in modern benchmarks to ensure real-valued x₂^{t_i})
# Source: de Villiers and Glasser (1981), as described in Jamil & Yang (2013).

export DEVILLIERSGLASSER2_FUNCTION, devilliersglasser2, devilliersglasser2_gradient

function devilliersglasser2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("devilliersglasser2 requires exactly 5 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    x1, x2, x3, x4, x5 = x

    sum_sq = zero(T)
    let m = 24
        t = T(0.1) .* (0:(m-1))   # t_i = 0.1 * (i-1), i=1:24
        y = similar(t)
        @inbounds for i in eachindex(t)
            ti = t[i]
            y[i] = T(53.81) * (T(1.27) ^ ti) * tanh(T(3.012)*ti + sin(T(2.13)*ti)) * cos(exp(T(0.507))*ti)
        end

        @inbounds for i in eachindex(t)
            ti = t[i]
            u = x3 * ti + sin(x4 * ti)
            v = ti * exp(x5)
            pow = x2 ^ ti                     # x2 ≥ 1.0 → immer real und stabil
            g = x1 * pow * tanh(u) * cos(v)
            sum_sq += (g - y[i])^2
        end
    end
    sum_sq
end

function devilliersglasser2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("devilliersglasser2 requires exactly 5 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    x1, x2, x3, x4, x5 = x
    grad = zeros(T, 5)

    let m = 24
        t = T(0.1) .* (0:(m-1))
        y = similar(t)
        @inbounds for i in eachindex(t)
            ti = t[i]
            y[i] = T(53.81) * (T(1.27) ^ ti) * tanh(T(3.012)*ti + sin(T(2.13)*ti)) * cos(exp(T(0.507))*ti)
        end

        @inbounds for i in eachindex(t)
            ti = t[i]
            u = x3 * ti + sin(x4 * ti)
            v = ti * exp(x5)
            pow = x2 ^ ti
            tanh_u = tanh(u)
            cos_v = cos(v)
            g = x1 * pow * tanh_u * cos_v
            e = g - y[i]
            sech2_u = one(T) - tanh_u^2
            sin_v = sin(v)

            # ∂/∂x1
            grad[1] += 2 * e * (pow * tanh_u * cos_v)
            # ∂/∂x2  (t=0 → pow=1, Ableitung=0)
            if ti > zero(T)
                grad[2] += 2 * e * (x1 * ti * pow / x2 * tanh_u * cos_v)
            end
            # ∂/∂x3
            grad[3] += 2 * e * (x1 * pow * sech2_u * ti * cos_v)
            # ∂/∂x4
            grad[4] += 2 * e * (x1 * pow * sech2_u * cos(x4 * ti) * ti * cos_v)
            # ∂/∂x5
            grad[5] += 2 * e * (x1 * pow * tanh_u * (-sin_v * v))
        end
    end
    grad
end

const DEVILLIERSGLASSER2_FUNCTION = TestFunction(
    devilliersglasser2,
    devilliersglasser2_gradient,
    Dict{Symbol, Any}(
        :name         => "devilliersglasser2",
        :description  => "De Villiers-Glasser function no. 2 (de Villiers and Glasser, 1981). Search space restricted to x_i ≥ 1.0 to ensure real-valued x₂^{t_i} (standard in modern benchmark implementations, e.g. AMPGO/Gavana, SciPy, pymoo, NLopt test suites). Original paper allows negative x₂ (complex values possible). Properties based on Jamil & Yang (2013).",
        :math         => raw"""f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \tanh(x_3 t_i + \sin(x_4 t_i)) \cos(t_i e^{x_5}) - y_i \right]^2,\quad t_i = 0.1(i-1),\quad y_i = 53.81 \cdot 1.27^{t_i} \tanh(3.012 t_i + \sin(2.13 t_i)) \cos(e^{0.507} t_i).""",
        :start        => () -> [10.0, 2.0, 3.0, 1.0, 0.5],   # weit weg vom Minimum → [RULE_START_AWAY_FROM_MIN]
        :min_position => () -> [53.81, 1.27, 3.012, 2.13, 0.507],
        :min_value    => () -> 0.0,
        :properties   => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :source       => "de Villiers and Glasser (1981); Jamil & Yang (2013)",
        :lb           => () -> fill(1.0, 5),
        :ub           => () -> fill(60.0, 5),
    )
)

