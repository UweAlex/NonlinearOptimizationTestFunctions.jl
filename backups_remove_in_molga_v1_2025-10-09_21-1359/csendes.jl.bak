# src/functions/csendes.jl
# Purpose: Implementation of the Csendes test function.
# Context: Scalable (n >= 1), continuous, differentiable, separable, multimodal. Source: Csendes and Ratz (1997), via Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[0,...,0].
# Bounds: -1 <= x_i <= 1.
# Last modified: September 24, 2025.

export CSENDES_FUNCTION, csendes, csendes_gradient

function csendes(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:n
        x_i = x[i]
        total += x_i^2 * (2 + sin(x_i))
    end
    return total
end

function csendes_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        x_i = x[i]
        sin_x = sin(x_i)
        cos_x = cos(x_i)
        grad[i] = 2 * x_i * (2 + sin_x) + x_i^2 * cos_x
    end
    return grad
end

const CSENDES_FUNCTION = TestFunction(
    csendes,
    csendes_gradient,
    Dict(
        :name => "csendes",
        :description => "Csendes function (continuous, differentiable, separable, scalable, multimodal). Source: Csendes and Ratz (1997). Global minimum f(x*)=0 at x*=(0,...,0).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n x_i^2 (2 + \sin x_i). """,
        :start => n -> fill(0.5, n),
        :min_position => n -> zeros(n),
        :min_value => n -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "separable", "scalable", "multimodal"],
        :default_n => 2,
        :lb => n -> fill(-1.0, n),
        :ub => n -> fill(1.0, n),
    )
)
