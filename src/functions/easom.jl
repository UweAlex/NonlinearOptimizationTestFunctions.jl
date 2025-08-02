# src/functions/easom.jl
# Purpose: Implements the Easom test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 21 July 2025

export EASOM_FUNCTION, easom, easom_gradient

using LinearAlgebra
using ForwardDiff

"""
    easom(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Easom function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function easom(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return -cos(x1) * cos(x2) * exp(-((x1 - pi)^2 + (x2 - pi)^2))
end

"""
    easom_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Easom function. Returns a vector of length 2.
"""
function easom_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    common = -cos(x1) * cos(x2) * exp(-((x1 - pi)^2 + (x2 - pi)^2))
    g1 = common * (sin(x1) / cos(x1) + 2 * (x1 - pi))
    g2 = common * (sin(x2) / cos(x2) + 2 * (x2 - pi))
    return [g1, g2]
end

const EASOM_FUNCTION = TestFunction(
    easom,
    easom_gradient,
    Dict(
        :name => "easom",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
            [pi, pi]
        end,
        :min_value => -1.0,
        :properties => Set(["unimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
            [-100.0, -100.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Easom requires exactly 2 dimensions"))
            [100.0, 100.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Easom function: Unimodal test function with a small global minimum area relative to the search space.",
        :math => "-\\cos(x_1)\\cos(x_2)\\exp(-((x_1-\\pi)^2 + (x_2-\\pi)^2))"
    )
)