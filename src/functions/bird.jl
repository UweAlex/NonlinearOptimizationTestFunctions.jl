# src/functions/bird.jl
# Purpose: Implements the Bird test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 03, 2025

export BIRD_FUNCTION, bird, bird_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Bird function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
function bird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sin(x[1]) * exp((1 - cos(x[2]))^2) + cos(x[2]) * exp((1 - sin(x[1]))^2) + (x[1] - x[2])^2
end #function

# Computes the gradient of the Bird function. Returns a vector of length 2.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
function bird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    grad = zeros(T, 2)
    grad[1] = cos(x[1]) * exp((1 - cos(x[2]))^2) - 2 * cos(x[1]) * (1 - sin(x[1])) * exp((1 - sin(x[1]))^2) * cos(x[2]) + 2 * (x[1] - x[2])
    grad[2] = sin(x[1]) * exp((1 - cos(x[2]))^2) * 2 * (1 - cos(x[2])) * sin(x[2]) - sin(x[2]) * exp((1 - sin(x[1]))^2) - 2 * (x[1] - x[2])
    return grad
end #function

const BIRD_FUNCTION = TestFunction(
    bird,
    bird_gradient,
    Dict(
        :name => "bird",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [4.701043130195973, 3.1529385037484228],  # Optimiertes Minimum
        :min_value => () -> -106.76453674926465,  # Optimierten Funktionswert
        :properties => Set(["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"]),
        :lb => () -> [-2π, -2π],
        :ub => () -> [2π, 2π],
        :description => "Bird function: Multimodal, non-convex, non-separable, differentiable, fixed.",
        :math => "\\sin(x_1) \\exp\\left((1 - \\cos(x_2))^2\\right) + \\cos(x_2) \\exp\\left((1 - \\sin(x_1))^2\\right) + (x_1 - x_2)^2"
    )
)
