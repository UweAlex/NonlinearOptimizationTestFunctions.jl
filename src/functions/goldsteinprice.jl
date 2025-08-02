# src/functions/goldsteinprice.jl
# Purpose: Implements the Goldstein-Price test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 18. Juli 2025

export GOLDSTEINPRICE_FUNCTION, goldsteinprice, goldsteinprice_gradient

using LinearAlgebra

"""
    goldsteinprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Goldstein-Price function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function goldsteinprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term1 = 1 + (x1 + x2 + 1)^2 * (19 - 14x1 + 3x1^2 - 14x2 + 6x1*x2 + 3x2^2)
    term2 = 30 + (2x1 - 3x2)^2 * (18 - 32x1 + 12x1^2 + 48x2 - 36x1*x2 + 27x2^2)
    return T(term1 * term2)
end

"""
    goldsteinprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Goldstein-Price function. Returns a vector of length 2.
"""
function goldsteinprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    # Term1: 1 + (x1 + x2 + 1)^2 * (19 - 14x1 + 3x1^2 - 14x2 + 6x1*x2 + 3x2^2)
    a = x1 + x2 + 1
    b = 19 - 14x1 + 3x1^2 - 14x2 + 6x1*x2 + 3x2^2
    term1 = 1 + a^2 * b
    # Term2: 30 + (2x1 - 3x2)^2 * (18 - 32x1 + 12x1^2 + 48x2 - 36x1*x2 + 27x2^2)
    c = 2x1 - 3x2
    d = 18 - 32x1 + 12x1^2 + 48x2 - 36x1*x2 + 27x2^2
    term2 = 30 + c^2 * d
    # Partielle Ableitungen
    da_dx1 = 1
    da_dx2 = 1
    db_dx1 = -14 + 6x1 + 6x2
    db_dx2 = -14 + 6x1 + 6x2
    dc_dx1 = 2
    dc_dx2 = -3
    dd_dx1 = -32 + 24x1 - 36x2
    dd_dx2 = 48 - 36x1 + 54x2
    grad1 = term2 * (2a * da_dx1 * b + a^2 * db_dx1) + term1 * (2c * dc_dx1 * d + c^2 * dd_dx1)
    grad2 = term2 * (2a * da_dx2 * b + a^2 * db_dx2) + term1 * (2c * dc_dx2 * d + c^2 * dd_dx2)
    return [T(grad1), T(grad2)]
end

const GOLDSTEINPRICE_FUNCTION = TestFunction(
    goldsteinprice,
    goldsteinprice_gradient,
    Dict(
        :name => "goldsteinprice",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
            [0.0, -1.0]
        end,
        :min_value => 3.0,
        :properties => Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
            [-2.0, -2.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Goldstein-Price requires exactly 2 dimensions"))
            [2.0, 2.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Goldstein-Price function: Multimodal, non-convex, non-separable, differentiable, bounded (n=2 only).",
        :math => "(1 + (x_1 + x_2 + 1)^2 (19 - 14x_1 + 3x_1^2 - 14x_2 + 6x_1x_2 + 3x_2^2)) \\cdot (30 + (2x_1 - 3x_2)^2 (18 - 32x_1 + 12x_1^2 + 48x_2 - 36x_1x_2 + 27x_2^2))"
    )
)