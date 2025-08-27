# src/functions/sineenvelope.jl
# Purpose: Implements the Sine Envelope test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 04 August 2025

export SINEENVELOPE_FUNCTION, sineenvelope, sineenvelope_gradient

using LinearAlgebra
using ..NonlinearOptimizationTestFunctions: TestFunction

"""
    sineenvelope(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Sine Envelope function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function sineenvelope(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    r = sqrt(x[1]^2 + x[2]^2)
    return -0.5 + (sin(r)^2 - 0.5) / (1 + 0.001 * r^2)^2
end

"""
    sineenvelope_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Sine Envelope function. Returns a vector of length 2.
"""
function sineenvelope_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    r2 = x[1]^2 + x[2]^2
    r = sqrt(r2)
    if r == 0
        return zeros(T, 2)
    end
    sin_r = sin(r)
    cos_r = cos(r)
    denom = (1 + 0.001 * r2)^3
    num = 2 * sin_r * cos_r * (1 + 0.001 * r2) - 0.004 * r * (sin_r^2 - 0.5)
    factor = num / denom / r
    return [x[1] * factor, x[2] * factor]
end

const SINEENVELOPE_FUNCTION = TestFunction(
    sineenvelope,
    sineenvelope_gradient,
    Dict(
        :name => "sineenvelope",
        :description => "Sine Envelope Test Function from Molga & Smutnicki (2005). Multimodal function with a global minimum at (0,0).",
        :math => "-0.5 + \\frac{\\sin^2(\\sqrt{x_1^2 + x_2^2}) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}",
        :min_value => -1.0,  # Korrigiert von -0.5 auf -1.0
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
            zeros(2)
        end,
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
            [1.0, 1.0]
        end,
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
            [-100.0, -100.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("SineEnvelope requires exactly 2 dimensions"))
            [100.0, 100.0]
        end,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded","continuous"]),
        :in_molga_smutnicki_2005 => true
    )
)