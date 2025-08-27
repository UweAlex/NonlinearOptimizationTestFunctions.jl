# src/functions/matyas.jl
# Purpose: Implements the Matyas test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export MATYAS_FUNCTION, matyas, matyas_gradient

using LinearAlgebra
using ForwardDiff

"""
    matyas(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Matyas function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function matyas(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Matyas requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return 0.26 * (x[1]^2 + x[2]^2) - 0.48 * x[1] * x[2]
end

"""
    matyas_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Matyas function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function matyas_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Matyas requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    return [0.52 * x[1] - 0.48 * x[2], 0.52 * x[2] - 0.48 * x[1]]
end

const MATYAS_FUNCTION = TestFunction(
    matyas,
    matyas_gradient,
    Dict(
        :name => "matyas",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => 0.0,
        :properties => Set(["unimodal", "convex", "non-separable", "differentiable", "bounded","continuous"]),
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Matyas function: Unimodal, convex, quadratic test function.",
        :math => "0.26 (x^2 + y^2) - 0.48 x y"
    )
)