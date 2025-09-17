# src/functions/powell.jl
# Purpose: Implements the Powell test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 29 August 2025, 10:21 AM CEST

export POWELL_FUNCTION, powell, powell_gradient

using LinearAlgebra
using ForwardDiff

function powell(x::AbstractVector)
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Powell requires exactly 4 dimensions"))
    any(isnan.(x)) && return NaN
    any(isinf.(x)) && return Inf
    x1, x2, x3, x4 = x
    term1 = (x1 + 10 * x2)^2
    term2 = 5 * (x3 - x4)^2
    term3 = (x2 - 2 * x3)^4
    term4 = 10 * (x1 - x4)^4
    return term1 + term2 + term3 + term4
end

function powell_gradient(x::AbstractVector)
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Powell requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(NaN, 4)
    any(isinf.(x)) && return fill(Inf, 4)
    x1, x2, x3, x4 = x
    grad = zeros(4)
    grad[1] = 2 * (x1 + 10 * x2) + 40 * (x1 - x4)^3
    grad[2] = 20 * (x1 + 10 * x2) + 4 * (x2 - 2 * x3)^3
    grad[3] = 10 * (x3 - x4) - 8 * (x2 - 2 * x3)^3
    grad[4] = -10 * (x3 - x4) - 40 * (x1 - x4)^3
    return grad
end

const POWELL_FUNCTION = TestFunction(
    powell,
    powell_gradient,
    Dict(
        :name => "powell",
        :start => () -> [3.0, -1.0, 0.0, 1.0],
        :min_position => () -> [0.0, 0.0, 0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => Set(["unimodal", "non-convex", "non-separable", "differentiable"]),
        :lb => () -> fill(-4.0, 4),
        :ub => () -> fill(5.0, 4),
        :in_molga_smutnicki_2005 => false,
        :description => "Powell function: Unimodal, non-convex, non-separable, differentiable. Global minimum at x = [0.0, 0.0, 0.0, 0.0] with f(x) = 0.0.",
        :math => "f(x) = (x_1 + 10x_2)^2 + 5(x_3 - x_4)^2 + (x_2 - 2x_3)^4 + 10(x_1 - x_4)^4"
    )
)
