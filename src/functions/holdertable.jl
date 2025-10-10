# src/functions/holdertable.jl
# Purpose: Implements the Holder Table test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 26, 2025

export HOLDERTABLE_FUNCTION, holdertable, holdertable_gradient

using LinearAlgebra
using ForwardDiff

"""
    holdertable(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Holder Table function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function holdertable(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Holder Table requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return -abs(sin(x1) * cos(x2) * exp(abs(1 - sqrt(x1^2 + x2^2) / pi)))
end

"""
    holdertable_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Holder Table function. Returns a vector of length 2.
"""
function holdertable_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Holder Table requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    if r == 0
        return fill(T(0), 2)  # Stabiler Grenzwert am Ursprung
    end
    exp_term = exp(abs(1 - r / pi))
    sign_outer = -sign(sin(x1) * cos(x2) * exp_term)
    inner = sin(x1) * cos(x2)
    sign_inner = sign(1 - r / pi)
    d_exp_dr = exp_term * sign_inner * (-1 / pi)
    dr_dx1 = x1 / r
    dr_dx2 = x2 / r
    df_dx1 = sign_outer * (cos(x1) * cos(x2) * exp_term + inner * d_exp_dr * dr_dx1)
    df_dx2 = sign_outer * (-sin(x1) * sin(x2) * exp_term + inner * d_exp_dr * dr_dx2)
    return [df_dx1, df_dx2]
end

const HOLDERTABLE_FUNCTION = TestFunction(
    holdertable,
    holdertable_gradient,
    Dict(
        :name => "holdertable",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [8.055023, 9.664590],
        :min_value => () -> -19.2085025678845,
        :properties => Set(["multimodal", "continuous", "partially differentiable", "separable", "bounded", "non-convex"]),
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
        :description => "Holder Table function: Multimodal, continuous, partially differentiable, separable, bounded, non-convex. Four global minima at (±8.055023, ±9.664590), f* = -19.2085025678845. Bounds: [-10, 10]^2. Dimensions: n=2.",
        :math => "-\\left| \\sin(x_1) \\cos(x_2) \\exp\\left(\\left|1 - \\sqrt{x_1^2 + x_2^2}/\\pi\\right|\\right) \\right|"
    )
)
