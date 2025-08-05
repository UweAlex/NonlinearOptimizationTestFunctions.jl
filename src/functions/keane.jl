# src/functions/keane.jl
# Purpose: Implements the Keane test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 05 August 2025

export KEANE_FUNCTION, keane, keane_gradient

using LinearAlgebra
using ForwardDiff

"""
    keane(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Keane function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function keane(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    norm_sq = x1^2 + x2^2
    norm_sq == 0 && return T(0.0)  # Avoid division by zero
    sin_diff = sin(x1 - x2)
    sin_sum = sin(x1 + x2)
    -(sin_diff^2 * sin_sum^2) / sqrt(norm_sq)  # Negatives Vorzeichen hinzugefügt
end

"""
    keane_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Keane function. Returns a vector of length 2.
"""
function keane_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
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
    grad1 = -(2 * sin_diff * cos_diff * sin_sum^2 + 2 * sin_diff^2 * sin_sum * cos_sum) / norm_sqrt + (x1 * term1) / (norm_sq^1.5)  # Vorzeichen angepasst
    grad2 = -(-2 * sin_diff * cos_diff * sin_sum^2 + 2 * sin_diff^2 * sin_sum * cos_sum) / norm_sqrt + (x2 * term1) / (norm_sq^1.5)  # Vorzeichen angepasst
    [grad1, grad2]
end

const KEANE_FUNCTION = TestFunction(
    keane,
    keane_gradient,
    Dict(
        :name => "keane",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
            [0.5, 0.5]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
            [0.0, 1.393249070031784]
        end,
        :min_value => -0.673667521146855,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
            [-10.0, -10.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Keane requires exactly 2 dimensions"))
            [10.0, 10.0]
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Keane function: Multimodal, non-convex, non-separable, differentiable test function with multiple global minima.",
        :math => "-\\frac{\\sin^2(x_1 - x_2) \\cdot \\sin^2(x_1 + x_2)}{\\sqrt{x_1^2 + x_2^2}}"
    )
)