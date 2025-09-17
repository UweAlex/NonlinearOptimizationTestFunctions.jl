# src/functions/sixhumpcamelback.jl
# Purpose: Implements the Six-Hump Camelback test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 15, 2025

export SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback, sixhumpcamelback_gradient

using LinearAlgebra
using ForwardDiff

# Constants for global minima
const SIXHUMPCAMELBACK_MINIMA = [
    [0.08984201368301331, -0.7126564032704135],
    [-0.08984201368301331, 0.7126564032704135]
]
const SIXHUMPCAMELBACK_MIN_VALUE = -1.031628453489877

function sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions, got $n"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term1 = (T(4) - T(2.1) * x1^2 + x1^4 / T(3)) * x1^2
    term2 = x1 * x2
    term3 = (T(-4) + T(4) * x2^2) * x2^2
    return term1 + term2 + term3
end

function sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions, got $n"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    grad_x1 = T(8) * x1 - T(8.4) * x1^3 + T(2) * x1^5 + x2
    grad_x2 = x1 - T(8) * x2 + T(16) * x2^3
    return [grad_x1, grad_x2]
end


const SIXHUMPCAMELBACK_FUNCTION = TestFunction(
    sixhumpcamelback,
    sixhumpcamelback_gradient,
    Dict(
        :name => "sixhumpcamelback",
        :start => () -> [0.0, 0.0],
        :min_position => () -> SIXHUMPCAMELBACK_MINIMA[1],
        :min_value => () -> SIXHUMPCAMELBACK_MIN_VALUE,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "continuous", "bounded"]),
        :lb => () -> [-3.0, -2.0],
        :ub => () -> [3.0, 2.0],
        :in_molga_smutnicki_2005 => true,
        :dimension => 2,
        :description => raw"Six-Hump Camelback function: A multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with six local minima and two global minima at (±0.08984201368301331, ∓0.7126564032704135) with value -1.031628453489877. References: Molga & Smutnicki (2005), Jamil & Yang (2013), al-roomi.org.",
        :math => raw"f(x) = \left(4 - 2.1 x_1^2 + \frac{x_1^4}{3}\right) x_1^2 + x_1 x_2 + (-4 + 4 x_2^2) x_2^2"
    )
)