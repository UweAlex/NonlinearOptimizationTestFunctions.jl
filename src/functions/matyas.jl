# src/functions/matyas.jl
# Purpose: Implementation of the Matyas test function.
# Global minimum: f(x*)=0.0 at x*=(0.0, 0.0).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export MATYAS_FUNCTION, matyas, matyas_gradient

using ForwardDiff

function matyas(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("matyas requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    0.26 * (x[1]^2 + x[2]^2) - 0.48 * x[1] * x[2]
end

function matyas_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("matyas requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    grad = zeros(T, 2)
    grad[1] = 0.52 * x[1] - 0.48 * x[2]
    grad[2] = 0.52 * x[2] - 0.48 * x[1]
    grad
end

const MATYAS_FUNCTION = TestFunction(
    matyas,
    matyas_gradient,
    Dict{Symbol, Any}(
        :name => "matyas",
        :description => "Matyas function; Properties based on Jamil & Yang (2013, p. 20).",
        :math => raw"""f(\mathbf{x}) = 0.26 (x_1^2 + x_2^2) - 0.48 x_1 x_2""",
        :start => () -> [4.0, 5.0] ,
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal", "convex", "bounded"],
        :source => "Jamil & Yang (2013, p. 20)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
