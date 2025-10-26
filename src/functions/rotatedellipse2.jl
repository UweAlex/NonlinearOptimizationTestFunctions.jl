# src/functions/rotatedellipse2.jl
# Purpose: Implementation of the Rotated Ellipse N.2 test function.
# Context: Part of NonlinearOptimizationTestFunctions. Non-scalable (fixed n=2), continuous, differentiable, non-separable, unimodal, convex quadratic function with rotated elliptical contours.
# Global minimum: f(x*)=0 at x*=(0, 0).
# Bounds: -500 ≤ x_i ≤ 500.
# Last modified: October 22, 2025.

export ROTATEDELLIPSE2_FUNCTION, rotatedellipse2, rotatedellipse2_gradient

using LinearAlgebra, ForwardDiff

"""
    rotatedellipse2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Rotated Ellipse N.2 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function rotatedellipse2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    sqrt3 = sqrt(3.0)
    7 * x1^2 - 6 * sqrt3 * x1 * x2 + 13 * x2^2
end

"""
    rotatedellipse2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Rotated Ellipse N.2 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function rotatedellipse2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x
    sqrt3 = sqrt(3.0)
    grad = zeros(T, 2)
    grad[1] = 14 * x1 - 6 * sqrt3 * x2
    grad[2] = -6 * sqrt3 * x1 + 26 * x2
    grad
end

const ROTATEDELLIPSE2_FUNCTION = TestFunction(
    rotatedellipse2,
    rotatedellipse2_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :description => "Rotated Ellipse N.2 function: A variant of the Rotated Ellipse, convex quadratic with elliptical contours rotated by cross-term. Properties based on [Jamil & Yang (2013, Entry 107)].",
        :math => raw"""f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal", "convex"],
        :source => "Jamil & Yang (2013, Entry 107)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)