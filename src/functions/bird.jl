# src/functions/bird.jl
# Purpose: Implements the Bird test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 16. August 2025

export BIRD_FUNCTION, bird, bird_gradient

using LinearAlgebra
using ForwardDiff

"""
    bird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Bird function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sin(x[1]) * exp((1 - cos(x[2]))^2) + cos(x[2]) * exp((1 - sin(x[1]))^2) + (x[1] - x[2])^2
end

"""
    bird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Bird function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    exp1 = exp((1 - cos(x[2]))^2)
    exp2 = exp((1 - sin(x[1]))^2)
    df_dx1 = cos(x[1]) * exp1 - 2 * cos(x[1]) * cos(x[2]) * (1 - sin(x[1])) * exp2 + 2 * (x[1] - x[2])
    df_dx2 = 2 * sin(x[2]) * sin(x[1]) * (1 - cos(x[2])) * exp1 - sin(x[2]) * exp2 - 2 * (x[1] - x[2])
    return [df_dx1, df_dx2]
end

const BIRD_FUNCTION = TestFunction(
    bird,
    bird_gradient,
    Dict(
        :name => "bird",
        :start => (n::Int) -> [0.0, 0.0],
        :min_position => (n::Int) -> [4.70104312, 3.15293848],  # Präziser Wert
        :min_value => -106.76453675,  # Präziser Wert
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int) -> [-2*pi, -2*pi],
        :ub => (n::Int) -> [2*pi, 2*pi],
        :in_molga_smutnicki_2005 => false,
        :description => "Bird function: Multimodal with two global minima.",
        :math => "\\sin(x) e^{(1-\\cos(y))^2} + \\cos(y) e^{(1-\\sin(x))^2} + (x - y)^2"
    )
)