# src/functions/beale.jl
# Purpose: Implements the Beale test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 25, 2025

export BEALE_FUNCTION, beale, beale_gradient

using LinearAlgebra
using ForwardDiff

"""
    beale(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Beale function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function beale(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Beale requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    t1 = 1.5 - x1 + x1 * x2
    t2 = 2.25 - x1 + x1 * x2^2
    t3 = 2.625 - x1 + x1 * x2^3
    return t1^2 + t2^2 + t3^2
end

"""
    beale_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Beale function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function beale_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Beale requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    t1 = 1.5 - x1 + x1 * x2
    t2 = 2.25 - x1 + x1 * x2^2
    t3 = 2.625 - x1 + x1 * x2^3
    grad = zeros(T, 2)
    grad[1] = 2 * t1 * (x2 - 1) + 2 * t2 * (x2^2 - 1) + 2 * t3 * (x2^3 - 1)
    grad[2] = 2 * t1 * x1 + 2 * t2 * 2 * x1 * x2 + 2 * t3 * 3 * x1 * x2^2
    return grad
end

const BEALE_FUNCTION = TestFunction(
    beale,
    beale_gradient,
    Dict(
        :name => "beale",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [3.0, 0.5],
        :min_value => 0.0,
        :properties => Set(["unimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-4.5, -4.5],
        :ub => () -> [4.5, 4.5],
        :in_molga_smutnicki_2005 => true,
        :description => "Beale function: Unimodal, non-convex, non-separable, differentiable, fixed, bounded, continuous.",
        :math => "(1.5 - x_1 + x_1 x_2)^2 + (2.25 - x_1 + x_1 x_2^2)^2 + (2.625 - x_1 + x_1 x_2^3)^2"
    )
)