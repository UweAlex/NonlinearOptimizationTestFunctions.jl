# src/functions/holdertable.jl
# Purpose: Implements the HolderTable test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 16. August 2025

export HOLDERTABLE_FUNCTION, holdertable, holdertable_gradient

using LinearAlgebra
using ForwardDiff

function holdertable(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("HolderTable requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return -abs(sin(x[1]) * cos(x[2]) * exp(abs(1 - sqrt(x[1]^2 + x[2]^2) / pi)))
end

function holdertable_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("HolderTable requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    r = sqrt(x[1]^2 + x[2]^2)
    if r == 0
        return fill(T(0), 2)  # Stabiler Grenzwert am Ursprung
    end
    exp_term = exp(abs(1 - r / pi))
    sign_outer = -sign(sin(x[1]) * cos(x[2]) * exp_term)
    inner = sin(x[1]) * cos(x[2])
    sign_inner = sign(1 - r / pi)
    d_exp_dr = exp_term * sign_inner * (-1 / pi)
    dr_dx1 = x[1] / r
    dr_dx2 = x[2] / r
    df_dx1 = sign_outer * (cos(x[1]) * cos(x[2]) * exp_term + inner * d_exp_dr * dr_dx1)
    df_dx2 = sign_outer * (-sin(x[1]) * sin(x[2]) * exp_term + inner * d_exp_dr * dr_dx2)
    return [df_dx1, df_dx2]
end

const HOLDERTABLE_FUNCTION = TestFunction(
    holdertable,
    holdertable_gradient,
    Dict(
        :name => "holdertable",
        :start => (n::Int) -> [0.0, 0.0],  # Zurück auf [0,0] für Konsistenz; Optimierung prüft nur Verbesserung
        :min_position => (n::Int) -> [8.055023475736176, 9.664590019238494],
        :min_value => -19.2085,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int) -> [-10.0, -10.0],
        :ub => (n::Int) -> [10.0, 10.0],
        :in_molga_smutnicki_2005 => true,
   :description => "HolderTable function: Multimodal with four global minima at [8.055023475736176, 9.664590019238494], [-8.055023475736176, 9.664590019238494], [8.055023475736176, -9.664590019238494], [-8.055023475736176, -9.664590019238494].",
        :math => "-|\\sin(x) \\cos(y) \\exp(|1 - \\sqrt{x^2 + y^2}/\\pi|)|"
    )
)