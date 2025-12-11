# src/functions/keane.jl
# Purpose: Implements the Keane test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 27, 2025

export KEANE_FUNCTION, keane, keane_gradient

using LinearAlgebra
using ForwardDiff

"""
    keane(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Keane function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.

The function is defined as `-(sin²(x₁ - x₂) * sin²(x₁ + x₂)) / sqrt(x₁² + x₂²)`, with a negative sign to achieve the global minimum value of -0.673668 at (0, 1.39325) and (1.39325, 0), as specified in Jamil & Yang (2013). The formula in Jamil & Yang (2013) omits the negative sign, likely a typo, as the non-negative form (due to sin² terms) cannot produce a negative minimum. This implementation aligns with other sources (e.g., Al-Roomi, 2015; INDUSMIC, 2021) that include the negative sign.
"""
function keane(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    norm_sq = x1^2 + x2^2
    norm_sq == 0 && return T(0.0)  # Avoid division by zero
    sin_diff = sin(x1 - x2)
    sin_sum = sin(x1 + x2)
    - (sin_diff^2 * sin_sum^2) / sqrt(norm_sq)  # Negative sign to match minimum value
end

"""
    keane_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Keane function. Returns a vector of length 2.
"""
function keane_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    norm_sq = x1^2 + x2^2
    norm_sq == 0 && return zeros(T, 2)  # Gradient at origin
    norm_sqrt = sqrt(norm_sq)
    sin_diff = sin(x1 - x2)
    cos_diff = cos(x1 - x2)
    sin_sum = sin(x1 + x2)
    cos_sum = cos(x1 + x2)
    term1 = sin_diff^2 * sin_sum^2
    grad1 = (2 * sin_diff * cos_diff * sin_sum^2 + 2 * sin_diff^2 * sin_sum * cos_sum) / norm_sqrt - (x1 * term1) / (norm_sq^1.5)
    grad2 = (-2 * sin_diff * cos_diff * sin_sum^2 + 2 * sin_diff^2 * sin_sum * cos_sum) / norm_sqrt - (x2 * term1) / (norm_sq^1.5)
    [-grad1, -grad2]  # Negate gradient to match -f(x)
end

const KEANE_FUNCTION = TestFunction(
    keane,
    keane_gradient,
    Dict(
        :name => "keane",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, 1.3932490753257145],
        :min_value => () ->   -0.6736675211468548,
        :properties => Set(["multimodal", "continuous", "differentiable", "non-separable", "bounded", "non-convex"]),
        :lb => () -> [0.0, 0.0],
        :ub => () -> [10.0, 10.0],
        :description => "Keane function: Multimodal, continuous, differentiable, non-separable, bounded, non-convex. Two global minima at (0.0, 1.39325) and (1.39325, 0.0), f* = -0.673668. Bounds: [0, 10]^2. Dimensions: n=2.",
        :math => "-\\frac{\\sin^2(x_1 - x_2) \\sin^2(x_1 + x_2)}{\\sqrt{x_1^2 + x_2^2}}"
    )
)