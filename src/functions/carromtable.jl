# src/functions/carromtable.jl
# Purpose: Implements the Carrom Table test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 02 September 2025

export CARROMTABLE_FUNCTION, carromtable, carromtable_gradient

using LinearAlgebra
using ForwardDiff

function carromtable(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("CarromTable requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term = abs(1 - sqrt(x1^2 + x2^2) / pi)
    return -((cos(x1) * cos(x2) * exp(term))^2) / 30
end

function carromtable_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("CarromTable requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    term = 1 - r / pi
    u = abs(term)
    v = cos(x1) * cos(x2) * exp(u)
    common = -2 * v / 30
    if r < 1e-10
        grad_x1 = common * (-sin(x1) * cos(x2) * exp(u))
        grad_x2 = common * (-cos(x1) * sin(x2) * exp(u))
    else
        grad_x1 = common * (-sin(x1) * cos(x2) * exp(u) + cos(x1) * cos(x2) * exp(u) * sign(term) * (-x1 / (pi * r)))
        grad_x2 = common * (-cos(x1) * sin(x2) * exp(u) + cos(x1) * cos(x2) * exp(u) * sign(term) * (-x2 / (pi * r)))
    end
    return [grad_x1, grad_x2]
end

const CARROMTABLE_FUNCTION = TestFunction(
    carromtable,
    carromtable_gradient,
    Dict(
        :name => "carromtable",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [9.646157266348881, 9.646134286497169],
        :min_value => -24.1568155,
        :properties => Set(["continuous", "partially differentiable", "non-separable", "multimodal", "non-convex", "bounded"]),
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Carrom Table function: Multimodal, non-convex, non-separable, partially differentiable, fixed dimension. Has four global minima.",
        :math => "-\\frac{\\left(\\cos(x_1)\\cos(x_2) \\exp \\left| 1 - \\frac{\\sqrt{x_1^2 + x_2^2}}{\\pi} \\right| \\right)^2}{30}"
    )
)