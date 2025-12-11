# src/functions/ursem_waves.jl
# Purpose: Implementation of the Ursem Waves test function.
# Global minimum: f(x*)=-8.5536 at x*=[1.2, 1.2].
# Bounds: -0.9 ≤ x1 ≤ 1.2, -1.2 ≤ x2 ≤ 1.2.

export URSEM_WAVES_FUNCTION, ursem_waves, ursem_waves_gradient

function ursem_waves(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem_waves requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1 = x[1]
    x2 = x[2]
    
    term1 = -0.9 * x1^2
    term2 = (x2^2 - 4.5 * x2^2) * x1 * x2
    term3 = 4.7 * cos(3 * x1 - x2^2 * (2 + x1)) * sin(2.5 * π * x1)
    
    term1 + term2 + term3
end

function ursem_waves_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem_waves requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1 = x[1]
    x2 = x[2]
    
    a = 3 * x1 - x2^2 * (2 + x1)
    b = 2.5 * π * x1
    
    # grad[1]
    grad[1] = -1.8 * x1 + (x2^3 - 4.5 * x2^3) + 4.7 * (-sin(a) * (3 - x2^2) * sin(b) + cos(a) * cos(b) * 2.5 * π)
    
    # grad[2]
    grad[2] = -10.5 * x1 * x2^2 + 4.7 * sin(a) * (2 * x2 * (2 + x1)) * sin(b)
    
    grad
end

const URSEM_WAVES_FUNCTION = TestFunction(
    ursem_waves,
    ursem_waves_gradient,
    Dict{Symbol, Any}(
        :name => "ursem_waves",
        :description => "The Ursem Waves function; Properties based on Jamil & Yang (2013, p. 36); has single global minimum and nine local minima.",
        :math => raw"""f(\mathbf{x}) = -0.9 x_1^2 + (x_2^2 - 4.5 x_2^2) x_1 x_2 + 4.7 \cos(3 x_1 - x_2^2 (2 + x_1)) \sin(2.5 \pi x_1). """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.2, 1.2],
        :min_value => () -> -8.5536,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source => "Jamil & Yang (2013, p. 36)",
        :lb => () -> [-0.9, -1.2],
        :ub => () -> [1.2, 1.2],
    )
)

# Optional: Validierung beim Laden
