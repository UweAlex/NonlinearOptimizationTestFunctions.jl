# src/functions/eggholder.jl
# Purpose: Implements the Eggholder test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 05 August 2025

export EGGHOLDER_FUNCTION, eggholder, eggholder_gradient

using LinearAlgebra
using ForwardDiff

"""
    eggholder(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Eggholder function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function eggholder(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    a = x2 + x1/2 + 47
    b = x1 - (x2 + 47)
    return - (x2 + 47) * sin(sqrt(abs(a))) - x1 * sin(sqrt(abs(b)))
end

"""
    eggholder_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Eggholder function. Returns a vector of length 2.
"""
function eggholder_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    a = x2 + x1/2 + 47
    b = x1 - (x2 + 47)
    sqrt_a = sqrt(abs(a))
    sqrt_b = sqrt(abs(b))
    sign_a = a >= 0 ? one(T) : -one(T)
    sign_b = b >= 0 ? one(T) : -one(T)
    grad_x1 = -sin(sqrt_b) - (x2 + 47) * cos(sqrt_a) * sign_a / (4 * sqrt_a) - x1 * cos(sqrt_b) * sign_b / (2 * sqrt_b)
    grad_x2 = -sin(sqrt_a) - (x2 + 47) * cos(sqrt_a) * sign_a / (2 * sqrt_a) + x1 * cos(sqrt_b) * sign_b / (2 * sqrt_b)
    return [grad_x1, grad_x2]
end

const EGGHOLDER_FUNCTION = TestFunction(
    eggholder,
    eggholder_gradient,
    Dict(
        :name => "eggholder",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
            [512.0, 404.2318058008512]
        end,
        :min_value => -959.6406627208506,
        :properties => Set(["multimodal", "differentiable", "non-convex", "non-separable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
            [-512.0, -512.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
            [512.0, 512.0]
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Eggholder function: A multimodal test function with many local minima, used for benchmarking nonlinear optimization algorithms.",
        :math => "- (x_2 + 47) \\sin\\left(\\sqrt{\\left|x_2 + \\frac{x_1}{2} + 47\\right|}\\right) - x_1 \\sin\\left(\\sqrt{\\left|x_1 - (x_2 + 47)\\right|}\\right)"
    )
)