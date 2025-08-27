# src/functions/dropwave.jl
# Purpose: Implements the Drop-Wave test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 26, 2025

export DROPWAVE_FUNCTION, dropwave, dropwave_gradient

using LinearAlgebra
using ForwardDiff

"""
    dropwave(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Drop-Wave function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function dropwave(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Drop-Wave requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    numerator = 1 + cos(12 * r)
    denominator = 0.5 * (x1^2 + x2^2) + 2
    return -numerator / denominator
end

"""
    dropwave_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Drop-Wave function. Returns a vector of length 2.
"""
function dropwave_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Drop-Wave requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    r2 = x1^2 + x2^2
    r = sqrt(r2)
    if r == 0
        return zeros(T, 2)
    end
    numerator = 1 + cos(12 * r)
    denominator = 0.5 * r2 + 2
    dr_numerator = -12 * sin(12 * r)
    dr_denominator = r
    factor = (12 * sin(12 * r) * (0.5 * r2 + 2) + (1 + cos(12 * r)) * r) / (r * denominator^2)
    grad = zeros(T, 2)
    grad[1] = factor * x1
    grad[2] = factor * x2
    return grad
end

const DROPWAVE_FUNCTION = TestFunction(
    dropwave,
    dropwave_gradient,
    Dict(
        :name => "dropwave",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => -1.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-5.12, -5.12],
        :ub => () -> [5.12, 5.12],
        :in_molga_smutnicki_2005 => true,
        :description => "Drop-Wave function: A multimodal, non-convex, non-separable, differentiable function defined for 2 dimensions, with a global minimum at [0, 0].",
        :math => "-\\frac{1 + \\cos(12 \\sqrt{x_1^2 + x_2^2})}{0.5 (x_1^2 + x_2^2) + 2}"
    )
)