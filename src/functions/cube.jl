# src/functions/cube.jl
# Purpose: Implementation of the Cube test function (f41).
# Context: Fixed n=2, continuous, differentiable, non-separable, unimodal. Source: Vogel (1966), via Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[1,1].
# Bounds: -10 <= x_i <= 10.
# Last modified: September 24, 2025.

export CUBE_FUNCTION, cube, cube_gradient

function cube(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Cube requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    term1 = x2 - x1^3
    return 100 * term1^2 + (1 - x1)^2
end

function cube_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Cube requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    term1 = x2 - x1^3
    g1 = 200 * term1 * (-3 * x1^2) - 2 * (1 - x1)
    g2 = 200 * term1
    grad = zeros(T, 2)
    grad[1] = g1
    grad[2] = g2
    return grad
end

const CUBE_FUNCTION = TestFunction(
    cube,
    cube_gradient,
    Dict(
        :name => "cube",
        :description => "Cube function (continuous, differentiable, non-separable, unimodal). Source: Vogel (1966). Global minimum f(x*)=0 at x*=(1,1).",
        :math => raw"""f(\mathbf{x}) = 100 (x_2 - x_1^3)^2 + (1 - x_1)^2. """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)