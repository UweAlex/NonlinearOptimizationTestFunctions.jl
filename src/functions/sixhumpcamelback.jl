# src/functions/sixhumpcamelback.jl
# Purpose: Implements the Six-Hump Camelback test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback, sixhumpcamelback_gradient

using LinearAlgebra
using ForwardDiff

"""
    sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Six-Hump Camelback function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term1 = (T(4) - T(2.1) * x1^2 + x1^4 / T(3)) * x1^2
    term2 = x1 * x2
    term3 = (T(-4) + T(4) * x2^2) * x2^2
    return term1 + term2 + term3
end

"""
    sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Six-Hump Camelback function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    grad1 = (T(8) - T(8.4) * x1^2 + T(2) * x1^4) * x1 + x2
    grad2 = x1 + (T(-8) + T(16) * x2^2) * x2
    return [grad1, grad2]
end

const SIXHUMPCAMELBACK_FUNCTION = TestFunction(
    sixhumpcamelback,
    sixhumpcamelback_gradient,
    Dict(
        :name => "sixhumpcamelback",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-0.08984201368301331, 0.7126564032704135],
        :min_value => -1.031628453489877,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "continuous", "bounded"]),
        :lb => () -> [-3.0, -2.0],
        :ub => () -> [3.0, 2.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Six-Hump Camelback function: Multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with six local minima, two global minima at (-0.08984201368301331, 0.7126564032704135) and (0.08984201368301331, -0.7126564032704135).",
        :math => "f(x) = \\left(4 - 2.1 x_1^2 + \\frac{x_1^4}{3}\\right) x_1^2 + x_1 x_2 + (-4 + 4 x_2^2) x_2^2"
    )
)