# src/functions/himmelblau.jl
# Purpose: Implements the Himmelblau test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 03 August 2025

export HIMMELBLAU_FUNCTION, himmelblau, himmelblau_gradient

using LinearAlgebra
using ForwardDiff

"""
    himmelblau(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Himmelblau function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function himmelblau(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return (x1^2 + x2 - 11)^2 + (x1 + x2^2 - 7)^2
end

"""
    himmelblau_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Himmelblau function. Returns a vector of length 2.
"""
function himmelblau_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    g1 = 4 * x1 * (x1^2 + x2 - 11) + 2 * (x1 + x2^2 - 7)
    g2 = 2 * (x1^2 + x2 - 11) + 4 * x2 * (x1 + x2^2 - 7)
    return [g1, g2]
end

const HIMMELBLAU_FUNCTION = TestFunction(
    himmelblau,
    himmelblau_gradient,
    Dict(
        :name => "himmelblau",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
            [3.0, 2.0]  # Eines der vier globalen Minima
        end,
        :min_value => 0.0,
        :properties => Set(["multimodal", "differentiable", "non-convex", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
            [-5.0, -5.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
            [5.0, 5.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Himmelblau function: A multimodal test function with four global minima.",
        :math => "(x_1^2 + x_2 - 11)^2 + (x_1 + x_2^2 - 7)^2"
    )
)