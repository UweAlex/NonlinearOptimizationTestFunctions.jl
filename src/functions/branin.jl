# src/functions/branin.jl
# Purpose: Implements the Branin test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 18. Juli 2025

export BRANIN_FUNCTION, branin, branin_gradient

using LinearAlgebra

"""
    branin(x::AbstractVector)
Computes the Branin function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function branin(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    a = 1.0
    b = 5.1 / (4.0 * π^2)
    c = 5.0 / π
    r = 6.0
    s = 10.0
    t = 1.0 / (8.0 * π)
    term1 = a * (x2 - b * x1^2 + c * x1 - r)^2
    term2 = s * (1.0 - t) * cos(x1)
    return term1 + term2 + s
end

"""
    branin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Branin function. Returns a vector of length 2.
"""
function branin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    x1, x2 = x
    a = 1.0
    b = 5.1 / (4.0 * π^2)
    c = 5.0 / π
    r = 6.0
    s = 10.0
    t = 1.0 / (8.0 * π)
    # Partielle Ableitungen
    df_dx1 = 2.0 * a * (x2 - b * x1^2 + c * x1 - r) * (-2.0 * b * x1 + c) - s * (1.0 - t) * sin(x1)
    df_dx2 = 2.0 * a * (x2 - b * x1^2 + c * x1 - r)
    return [df_dx1, df_dx2]
end

const BRANIN_FUNCTION = TestFunction(
    branin,
    branin_gradient,
    Dict(
        :name => "branin",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
            [-π, 12.275]  # Eines der drei globalen Minima
        end,
        :min_value => 0.397887,
        :properties => Set(["multimodal", "differentiable", "non-convex", "non-separable", "bounded","continuous"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
            [-5.0, 0.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Branin function requires exactly 2 dimensions"))
            [10.0, 15.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Branin function: A multimodal, non-convex function with three global minima at [-π, 12.275], [π, 2.275], [9.424778, 2.475]. Only defined for n=2.",
        :math => "f(x) = a (x_2 - b x_1^2 + c x_1 - r)^2 + s (1 - t) \\cos(x_1) + s, a=1, b=5.1/(4\\pi^2), c=5/\\pi, r=6, s=10, t=1/(8\\pi)"
    )
)