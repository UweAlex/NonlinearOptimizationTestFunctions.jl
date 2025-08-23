# src/functions/crossintray.jl
# Purpose: Implements the Cross-in-Tray test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 05 August 2025

export CROSSINTRAY_FUNCTION, crossintray, crossintray_gradient

using LinearAlgebra
using ForwardDiff

"""
    crossintray(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Cross-in-Tray function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function crossintray(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    inner = abs(sin(x1) * sin(x2) * exp(abs(100 - sqrt(x1^2 + x2^2) / pi)))
    return -0.0001 * (inner + 1)^0.1
end

"""
    crossintray_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Cross-in-Tray function. Returns a vector of length 2.
"""
function crossintray_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    norm_x = sqrt(x1^2 + x2^2)
    norm_x == 0 && return fill(T(0), 2)  # Handle origin
    a = abs(100 - norm_x / pi)
    inner = sin(x1) * sin(x2) * exp(a)
    inner_abs = abs(inner)
    sign_inner = inner >= 0 ? 1 : -1
    sign_a = (100 - norm_x / pi) >= 0 ? 1 : -1
    term1 = -0.00001 * (inner_abs + 1)^(-0.9) * sign_inner
    term2 = cos(x1) * sin(x2) * exp(a)
    term3 = sin(x1) * cos(x2) * exp(a)
    term4 = -sin(x1) * sin(x2) * exp(a) * sign_a * x1 / (pi * norm_x)
    term5 = -sin(x1) * sin(x2) * exp(a) * sign_a * x2 / (pi * norm_x)
    grad1 = term1 * (term2 + term4)
    grad2 = term1 * (term3 + term5)
    return [grad1, grad2]
end

const CROSSINTRAY_FUNCTION = TestFunction(
    crossintray,
    crossintray_gradient,
    Dict(
        :name => "crossintray",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
            [1.349406575769872, 1.349406575769872]  # One of the four global minima
        end,
        :min_value => -2.062611237,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
            [-10.0, -10.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Cross-in-Tray requires exactly 2 dimensions"))
            [10.0, 10.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Cross-in-Tray function: A multimodal, non-convex, non-separable test function with four global minima at [1.349406575769872, 1.349406575769872], [-1.349406575769872, 1.349406575769872], [1.349406575769872, -1.349406575769872], [-1.349406575769872, -1.349406575769872].",
        :math => "-0.0001 \\left( \\left| \\sin(x_1) \\sin(x_2) \\exp\\left( \\left| 100 - \\frac{\\sqrt{x_1^2 + x_2^2}}{\\pi} \\right| \\right) \\right| + 1 \\right)^{0.1}"
    )
)