# src/functions/deckkersaarts.jl
# Purpose: Implements the Deckkers-Aarts test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 17 August 2025

export DECKKERSAARTS_FUNCTION, deckkersaarts, deckkersaarts_gradient

using LinearAlgebra
using ForwardDiff

"""
    deckkersaarts(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Deckkers-Aarts function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function deckkersaarts(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    s = x[1]^2 + x[2]^2
    return 1e5 * x[1]^2 + x[2]^2 - s^2 + 1e-5 * s^4
end

"""
    deckkersaarts_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Deckkers-Aarts function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function deckkersaarts_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    s = x[1]^2 + x[2]^2
    df_dx1 = 2 * 1e5 * x[1] - 4 * x[1] * s + 8 * 1e-5 * x[1] * s^3
    df_dx2 = 2 * x[2] - 4 * x[2] * s + 8 * 1e-5 * x[2] * s^3
    return [df_dx1, df_dx2]
end

const DECKKERSAARTS_FUNCTION = TestFunction(
    deckkersaarts,
    deckkersaarts_gradient,
    Dict(
        :name => "deckkersaarts",
        :start => (n::Int) -> begin
            n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
            [0.0, 10.0]
        end,
        :min_position => (n::Int) -> begin
            n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
            [0.0, 14.945108]
        end,
        :min_value => -24776.51834228699,  # Korrigierter Wert basierend auf Julia-Berechnung
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int) -> begin
            n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
            [-20.0, -20.0]
        end,
        :ub => (n::Int) -> begin
            n != 2 && throw(ArgumentError("DeckkersAarts requires exactly 2 dimensions"))
            [20.0, 20.0]
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Deckkers-Aarts function: Multimodal with two global minima at (0, ±14.945108). Note: Literature (Jamil & Yang, 2013) reports minimum as -24771.09375, but computation yields -24776.51834228699.",
        :math => "10^5 x_1^2 + x_2^2 - (x_1^2 + x_2^2)^2 + 10^{-5} (x_1^2 + x_2^2)^4"
    )
)