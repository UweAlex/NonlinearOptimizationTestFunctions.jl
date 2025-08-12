# src/functions/zakharov.jl
# Purpose: Implements the Zakharov test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 12, 2025

export ZAKHAROV_FUNCTION, zakharov, zakharov_gradient

using LinearAlgebra
using ForwardDiff

"""
    zakharov(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Zakharov function value at point `x`. Scalable to any dimension n >= 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function zakharov(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum_sq = dot(x, x)
    s = sum(0.5 * i * x[i] for i in 1:n)
    return sum_sq + s^2 + s^4
end

"""
    zakharov_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Zakharov function. Returns a vector of length n.
"""
function zakharov_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    s = sum(0.5 * i * x[i] for i in 1:n)
    grad = zeros(T, n)
    for k in 1:n
        grad[k] = 2 * x[k] + k * s + 2 * k * s^3
    end
    return grad
end

const ZAKHAROV_FUNCTION = TestFunction(
    zakharov,
    zakharov_gradient,
    Dict(
        :name => "zakharov",
        :start => (n::Int) -> ones(n),
        :min_position => (n::Int) -> zeros(n),
        :min_value => 0.0,
        :properties => Set(["unimodal", "convex", "non-separable", "differentiable", "scalable"]),
        :lb => (n::Int) -> fill(-5.0, n),
        :ub => (n::Int) -> fill(10.0, n),
        :in_molga_smutnicki_2005 => true,
        :description => "Zakharov function: A scalable, unimodal, convex test function for optimization.",
        :math => "\\sum_{i=1}^n x_i^2 + \\left( \\sum_{i=1}^n 0.5 i x_i \\right)^2 + \\left( \\sum_{i=1}^n 0.5 i x_i \\right)^4"
    )
)