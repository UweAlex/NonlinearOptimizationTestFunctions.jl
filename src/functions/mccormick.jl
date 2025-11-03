# src/functions/mccormick.jl
# Purpose: Implements the McCormick test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 25 August 2025

export MCCORMICK_FUNCTION, mccormick, mccormick_gradient

using LinearAlgebra
using ForwardDiff

# Computes the McCormick function value at point `x`. Requires dimension n = 2.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
function mccormick(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("McCormick requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return sin(x1 + x2) + (x1 - x2)^2 - 1.5 * x1 + 2.5 * x2 + 1
end #function

# Computes the gradient of the McCormick function. Returns a vector of length 2.
function mccormick_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("McCormick requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    grad = zeros(T, 2)
    grad[1] = cos(x1 + x2) + 2 * (x1 - x2) - 1.5
    grad[2] = cos(x1 + x2) - 2 * (x1 - x2) + 2.5
    return grad
end #function

const MCCORMICK_FUNCTION = TestFunction(
    mccormick,
    mccormick_gradient,
    Dict(
        :name => "mccormick",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-0.54719755, -1.54719755],
        :min_value => () -> -1.9132229549810367,
        :properties => Set(["differentiable", "non-convex", "multimodal", "bounded", "continuous"]),
        :lb => () -> [-1.5, -3.0],
        :ub => () -> [4.0, 4.0],
        :source => "molga&smutnicki(2005)",
        :description => "McCormick function: Multimodal, non-convex function with global minimum at approximately -1.91322295, defined for 2 dimensions.",
        :math => "\\sin(x_1 + x_2) + (x_1 - x_2)^2 - 1.5 x_1 + 2.5 x_2 + 1"
    )
)