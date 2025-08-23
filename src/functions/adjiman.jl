# src/functions/adjiman.jl
# Purpose: Implements the Adjiman test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 21, 2025

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
end

"""
    adjiman_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Adjiman function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function adjiman_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad1 = -sin(x[1]) * sin(x[2]) - T(1.0) / (x[2]^2 + T(1.0))
    grad2 = cos(x[1]) * cos(x[2]) + x[1] * T(2.0) * x[2] / (x[2]^2 + T(1.0))^2
    return [grad1, grad2]
end

const ADJIMAN_META = Dict(
    :name => "adjiman",
    :start => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
        [0.0, 0.0]
    end,
    :min_position => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
        [2.0, 0.10578347]
    end,
    :min_value => -2.021806783359787,
    :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "continuous", "bounded"]),
    :lb => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
        [-1.0, -1.0]
    end,
    :ub => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Adjiman requires exactly 2 dimensions"))
        [2.0, 1.0]
    end,
    :in_molga_smutnicki_2005 => false,
    :description => "Adjiman function: Continuous, differentiable, non-separable, non-scalable, multimodal.",
    :math => "\\f(x) = \\cos(x_1) \\sin(x_2) - \\frac{x_1}{x_2^2 + 1}"
)

const ADJIMAN_FUNCTION = TestFunction(
    adjiman,
    adjiman_gradient,
    ADJIMAN_META
)