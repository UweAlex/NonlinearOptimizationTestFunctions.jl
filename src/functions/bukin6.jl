# src/functions/bukin6.jl
# Purpose: Implements the Bukin function N.6 with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 02 August 2025

export BUKIN6_FUNCTION, bukin6, bukin6_gradient

using LinearAlgebra
using ForwardDiff

"""
    bukin6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Bukin function N.6 value at point `x`. Requires dimension n = 2.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function bukin6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Bukin N.6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    u = x2 - 0.01 * x1^2
    v = x1 + 10
    return 100 * sqrt(abs(u)) + 0.01 * abs(v)
end

"""
    bukin6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Bukin function N.6. Returns a vector of length 2.
Returns `NaN` at non-differentiable points (x2 = 0.01 * x1^2 or x1 = -10).
"""
function bukin6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Bukin N.6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    u = x2 - 0.01 * x1^2
    v = x1 + 10
    grad = zeros(T, 2)
    if u == 0 || v == 0
        grad .= T(NaN)
    else
        grad[1] = -x1 * sign(u) / sqrt(abs(u)) + 0.01 * sign(v)
        grad[2] = 50 * sign(u) / sqrt(abs(u))
    end
    return grad
end

const BUKIN6_FUNCTION = TestFunction(
    bukin6,
    bukin6_gradient,
    Dict(
        :name => "bukin6",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-10.0, 1.0],
        :min_value => 0.0,
        :properties => Set(["partially differentiable", "non-convex", "multimodal", "bounded", "continuous"]),
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Bukin function N.6: Multimodal, partially differentiable, non-convex function with global minimum at zero, defined for 2 dimensions.",
        :math => "100 \\sqrt{|x_2 - 0.01 x_1^2|} + 0.01 |x_1 + 10|"
    )
)