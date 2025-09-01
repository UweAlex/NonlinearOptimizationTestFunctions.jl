# src/functions/freudensteinroth.jl
# Purpose: Implements the Freudenstein-Roth test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 31 August 2025

export FREUDENSTEINROTH_FUNCTION, freudensteinroth, freudensteinroth_gradient

using LinearAlgebra
using ForwardDiff

function freudensteinroth(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("FreudensteinRoth requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    a = x1 - 13 + ((5 - x2) * x2 - 2) * x2
    b = x1 - 29 + ((x2 + 1) * x2 - 14) * x2
    return a^2 + b^2
end

function freudensteinroth_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("FreudensteinRoth requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    a = x1 - 13 + ((5 - x2) * x2 - 2) * x2
    b = x1 - 29 + ((x2 + 1) * x2 - 14) * x2
    grad = zeros(T, 2)
    grad[1] = 2 * (a + b)
    grad[2] = 2 * a * ((5 - x2) * x2 - 2 * x2) + 2 * b * ((x2 + 1) * x2 - 14 * x2 + x2 * (x2 + 1))
    return grad
end

const FREUDENSTEINROTH_FUNCTION = TestFunction(
    freudensteinroth,
    freudensteinroth_gradient,
    Dict(
        :name => "freudensteinroth",
        :start => () -> [4.99, 3.99],  # 100-mal näher am Minimum [5.0, 4.0]
        :min_position => () -> [5.0, 4.0],
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> fill(-10.0, 2),
        :ub => () -> fill(10.0, 2),
        :in_molga_smutnicki_2005 => false,  # Nicht in Molga2005.txt
        :description => "Freudenstein-Roth function: Multimodal, non-convex, non-separable, differentiable, fixed dimension (n=2).",
        :math => "f(x) = \\left( x_1 - 13 + \\left( (5 - x_2)x_2 - 2 \\right)x_2 \\right)^2 + \\left( x_1 - 29 + \\left( (x_2 + 1)x_2 - 14 \\right)x_2 \\right)^2"
    )
)