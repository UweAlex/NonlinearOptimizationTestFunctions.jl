# src/functions/threehumpcamel.jl
# Purpose: Implements the Three-Hump Camel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export THREEHUMPCAMEL_FUNCTION, threehumpcamel, threehumpcamel_gradient

using LinearAlgebra
using ForwardDiff

"""
    threehumpcamel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Three-Hump Camel function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function threehumpcamel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return T(2.0) * x1^2 - T(1.05) * x1^4 + (x1^6) / T(6.0) + x1 * x2 + x2^2
end

"""
    threehumpcamel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Three-Hump Camel function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function threehumpcamel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    g1 = T(4.0) * x1 - T(4.2) * x1^3 + x1^5 + x2
    g2 = x1 + T(2.0) * x2
    return [g1, g2]
end

const THREEHUMPCAMEL_FUNCTION = TestFunction(
    threehumpcamel,
    threehumpcamel_gradient,
    Dict(
        :name => "threehumpcamel",
        :start => () -> [2.0, 2.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded","continuous"]),
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0],
        :description => "Three-Hump Camel function: Multimodal, non-convex, non-separable, differentiable, bounded test function with three local minima and a global minimum at (0.0, 0.0).",
        :math => "2x_1^2 - 1.05x_1^4 + \\frac{x_1^6}{6} + x_1 x_2 + x_2^2"
    )
)
