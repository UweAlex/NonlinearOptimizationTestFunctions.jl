# src/functions/bukin6.jl
# Purpose: Implements the Bukin6 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 25 August 2025

export BUKIN6_FUNCTION, bukin6, bukin6_gradient

using LinearAlgebra
using ForwardDiff

"""
    bukin6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Bukin6 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bukin6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return 100 * sqrt(abs(x[2] - 0.01 * x[1]^2)) + 0.01 * abs(x[1] + 10)
end

"""
    bukin6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Bukin6 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bukin6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    grad = zeros(T, 2)
    diff_term = x[2] - 0.01 * x[1]^2
    # Partial derivative w.r.t x1
    grad[1] = abs(diff_term) > 1e-10 ? -0.2 * x[1] * sign(diff_term) / sqrt(abs(diff_term)) : zero(T)
    grad[1] += 0.01 * sign(x[1] + 10)
    # Partial derivative w.r.t x2
    grad[2] = abs(diff_term) > 1e-10 ? 50 * sign(diff_term) / sqrt(abs(diff_term)) : zero(T)
    return grad
end

const BUKIN6_FUNCTION = TestFunction(
    bukin6,
    bukin6_gradient,
    Dict(
        :name => "bukin6",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-10.0, 1.0],
        :min_value =>  () -> 0.0,
        :properties => Set(["bounded", "continuous", "partially differentiable", "non-convex", "multimodal"]),
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Bukin6 function: Multimodal, non-convex, partially differentiable, bounded, continuous.",
        :math => "100 \\sqrt{|x_2 - 0.01 x_1^2|} + 0.01 |x_1 + 10|"
    )
)