# src/functions/
# Purpose: Implementation of the Parsopoulos test function.
# Context: Non-scalable, 2D multimodal function from Parsopoulos et al., as f85 in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[π/2, 0].
# Bounds: -5 ≤ x_i ≤ 5.
# Last modified: September 29, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export PARSOPOULOS_FUNCTION, parsopoulos, parsopoulos_gradient

function parsopoulos(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Parsopoulos requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    return cos(x1)^2 + sin(x2)^2
end

function parsopoulos_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Parsopoulos requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    c1, s1 = cos(x1), sin(x1)
    s2, c2 = sin(x2), cos(x2)
    
    grad = zeros(T, 2)
    grad[1] = -2 * c1 * s1  # -sin(2 x1)
    grad[2] = 2 * s2 * c2   # sin(2 x2)
    return grad
end

const PARSOPOULOS_FUNCTION = TestFunction(
    parsopoulos,
    parsopoulos_gradient,
    Dict(
        :name => "parsopoulos",
        :description => "Parsopoulos Function: 2D multimodal periodic function with infinite minima. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \cos^2(x_1) + \sin^2(x_2).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [π/2, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "separable", "non-convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Parsopoulos et al., via Jamil & Yang (2013): f85",
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0]
    )
)