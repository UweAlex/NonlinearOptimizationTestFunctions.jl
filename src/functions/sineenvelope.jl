# src/functions/sineenvelope.jl
# Purpose: Implements the Sine Envelope test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 03 August 2025

export SINEENVELOPE_FUNCTION, sineenvelope, sineenvelope_gradient

using LinearAlgebra
using ForwardDiff

"""
    sineenvelope(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Sine Envelope function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function sineenvelope(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    r = sqrt(x[1]^2 + x[2]^2)
    sin_r_sq = sin(r)^2
    r_sq = x[1]^2 + x[2]^2
    return -(sin_r_sq + 0.5 * r_sq) * (0.5 + sin_r_sq / (1 + 0.001 * r_sq^2))
end

"""
    sineenvelope_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Sine Envelope function. Returns a vector of length 2.
"""
function sineenvelope_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    r = sqrt(x[1]^2 + x[2]^2)
    r == 0 && return zeros(T, 2)
    sin_r = sin(r)
    cos_r = cos(r)
    sin_r_sq = sin_r^2
    r_sq = x[1]^2 + x[2]^2
    term1 = sin_r_sq + 0.5 * r_sq
    term2 = 0.5 + sin_r_sq / (1 + 0.001 * r_sq^2)
    dterm1_dx = [2 * sin_r * cos_r * (x[1] / r) + x[1], 2 * sin_r * cos_r * (x[2] / r) + x[2]]
    dterm2_dx = [(x[1] / r) * (2 * sin_r * cos_r * (1 + 0.001 * r_sq^2) - 0.004 * r_sq * r * sin_r_sq) / (1 + 0.001 * r_sq^2)^2,
                 (x[2] / r) * (2 * sin_r * cos_r * (1 + 0.001 * r_sq^2) - 0.004 * r_sq * r * sin_r_sq) / (1 + 0.001 * r_sq^2)^2]
    return -(dterm1_dx * term2 + term1 * dterm2_dx)
end
const SINEENVELOPE_FUNCTION = TestFunction(
    sineenvelope,
    sineenvelope_gradient,
    Dict(
        :name => "sineenvelope",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
            [1.0, 1.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
            [1.538637632553666, 1.1370027579926583]  # Aktualisiertes Minimum
        end,
        :min_value => -3.7379439163636463,  # Unverändert, da exakt
        :properties => Set(["multimodal", "differentiable", "non-separable"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
            [-100.0, -100.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Sine Envelope requires exactly 2 dimensions"))
            [100.0, 100.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Sine Envelope function: A multimodal, differentiable, non-separable function with multiple local minima, defined only for 2 dimensions.",
        :math => "-\\left( \\sin^2(\\sqrt{x_1^2 + x_2^2}) + 0.5 (x_1^2 + x_2^2) \\right) \\cdot \\left( 0.5 + \\frac{\\sin^2(\\sqrt{x_1^2 + x_2^2})}{1 + 0.001 (x_1^2 + x_2^2)^2} \\right)"
    )
)