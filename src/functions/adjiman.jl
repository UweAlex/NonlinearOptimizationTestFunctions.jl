# src/functions/adjiman.jl
# Purpose: Implements the Adjiman test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export ADJIMAN_FUNCTION, adjiman, adjiman_gradient

using LinearAlgebra
using ForwardDiff

"""
    adjiman(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Adjiman function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function adjiman(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return cos(x[1]) * sin(x[2]) - x[1] / (x[2]^2 + T(1.0))
end #function

"""
    adjiman_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Adjiman function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function adjiman_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    grad1 = -sin(x[1]) * sin(x[2]) - T(1.0) / (x[2]^2 + T(1.0))
    grad2 = cos(x[1]) * cos(x[2]) + x[1] * T(2.0) * x[2] / (x[2]^2 + T(1.0))^2
    return [grad1, grad2]
end #function

const ADJIMAN_FUNCTION = TestFunction(
    adjiman,
    adjiman_gradient,
    Dict(
        :name => "adjiman",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [2.0, 0.10578347],
        :min_value => () -> -2.021806783359787,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-1.0, -1.0],
        :ub => () -> [2.0, 1.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Adjiman function: Multimodal, non-convex, non-separable, differentiable, bounded test function with a single global minimum at (2.0, 0.10578347).",
        :math => "\\cos(x_1) \\sin(x_2) - \\frac{x_1}{x_2^2 + 1}"
    )
)