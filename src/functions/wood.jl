# src/functions/wood.jl
# Purpose: Implements the Wood test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 27 August 2025

export WOOD_FUNCTION, wood, wood_gradient

using LinearAlgebra

"""
    wood(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Wood function value at point `x`. Requires exactly 4 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function wood(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Wood requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2, x3, x4 = x
    term1 = 100 * (x1^2 - x2)^2
    term2 = (x1 - 1)^2
    term3 = (x3 - 1)^2
    term4 = 90 * (x3^2 - x4)^2
    term5 = 10.1 * ((x2 - 1)^2 + (x4 - 1)^2)
    term6 = 19.8 * (x2 - 1) * (x4 - 1)
    return term1 + term2 + term3 + term4 + term5 + term6
end

"""
    wood_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Wood function. Returns a vector of length 4.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function wood_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Wood requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    x1, x2, x3, x4 = x
    grad1 = 400 * x1 * (x1^2 - x2) + 2 * (x1 - 1)
    grad2 = -200 * (x1^2 - x2) + 20.2 * (x2 - 1) + 19.8 * (x4 - 1)
    grad3 = 2 * (x3 - 1) + 360 * x3 * (x3^2 - x4)
    grad4 = -180 * (x3^2 - x4) + 20.2 * (x4 - 1) + 19.8 * (x2 - 1)
    return [grad1, grad2, grad3, grad4]
end

const WOOD_FUNCTION = TestFunction(
    wood,
    wood_gradient,
    Dict(
        :name => "wood",
        :start => () -> [0.0, 0.0, 0.0, 0.0],
        :min_position => () -> [1.0, 1.0, 1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> fill(-10.0, 4),
        :ub => () -> fill(10.0, 4),
        :in_molga_smutnicki_2005 => false,
        :description => "Wood function: Multimodal, non-convex, non-separable, differentiable test function with a single global minimum. Also known as Colville function.",
        :math => "f(x) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)"
    )
)
