# src/functions/chichinadze.jl
# Purpose: Implementation of the Chichinadze test function.
# Context: Non-scalable (n=2), separable, multimodal. Source: Jamil & Yang (2013), validated via al-roomi.org.
# Global minimum: f(x*)=-42.944387018991 at x*≈[6.18986658696568, 0.5].
# Bounds: -30 ≤ x_i ≤ 30.
# Last modified: September 24, 2025.

export CHICHINADZE_FUNCTION, chichinadze, chichinadze_gradient

using LinearAlgebra: norm  # Nicht benötigt, aber für potenzielle Erweiterungen

function chichinadze(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Chichinadze requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    π_val = T(π)
    term1 = x1^2 - 12 * x1 + 11
    term2 = 10 * cos(π_val * x1 / 2)
    term3 = 8 * sin(5 * π_val * x1 / 2)
    term4 = - (T(1)/5)^0.5 * exp(-T(0.5) * (x2 - T(0.5))^2)
    return term1 + term2 + term3 + term4
end

function chichinadze_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Chichinadze requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    π_val = T(π)
    g1 = 2 * x1 - 12 - 5 * π_val * sin(π_val * x1 / 2) + 20 * π_val * cos(5 * π_val * x1 / 2)
    c = (T(1)/5)^0.5
    d = x2 - T(0.5)
    g2 = c * d * exp(-T(0.5) * d^2)
    return [g1, g2]
end

const CHICHINADZE_FUNCTION = TestFunction(
    chichinadze,
    chichinadze_gradient,
    Dict(
        :name => "chichinadze",
        :description => "Chichinadze function (continuous, differentiable, separable, non-scalable, multimodal). Source: Jamil & Yang (2013). Global minimum at approximately [6.18987, 0.5].",
        :math => raw"""f(\mathbf{x}) = x_1^2 - 12 x_1 + 11 + 10 \cos\left(\frac{\pi x_1}{2}\right) + 8 \sin\left(\frac{5 \pi x_1}{2}\right) - \sqrt{\frac{1}{5}} \exp\left(-0.5 (x_2 - 0.5)^2 \right) """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [6.18986658696568, 0.5],
        :min_value => () -> -42.944387018991,
        :properties => ["bounded", "continuous", "differentiable", "separable", "multimodal"],
        :lb => () -> [-30.0, -30.0],
        :ub => () -> [30.0, 30.0],
    )
)