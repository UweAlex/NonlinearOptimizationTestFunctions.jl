# src/functions/sumofpowers.jl
# Purpose: Implements the Sum of Powers test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 03 August 2025

export SUMOFPOWERS_FUNCTION, sumofpowers, sumofpowers_gradient

using LinearAlgebra
using ForwardDiff

"""
    sumofpowers(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Sum of Powers function value at point `x`. Supports any dimension `n`.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function sumofpowers(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sum(abs(x[i])^(i+1) for i in 1:length(x))
end

"""
    sumofpowers_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Sum of Powers function. Returns a vector of length `n`.
"""
function sumofpowers_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    return [(i+1) * abs(x[i])^i * sign(x[i]) for i in 1:n]
end

const SUMOFPOWERS_FUNCTION = TestFunction(
    sumofpowers,
    sumofpowers_gradient,
    Dict(
        :name => "sumofpowers",
        :start => (n::Int) -> fill(0.5, n),
        :min_position => (n::Int) -> zeros(n),
        :min_value => 0.0,
        :properties => Set(["unimodal", "convex", "differentiable", "separable", "scalable","bounded","continuous"]),
        :lb => (n::Int) -> fill(-1.0, n),
        :ub => (n::Int) -> fill(1.0, n),
        :in_molga_smutnicki_2005 => true,
        :description => "Sum of Powers function: A unimodal, convex, differentiable, separable, and scalable function with a single global minimum.",
        :math => "\\sum_{i=1}^n |x_i|^{i+1}"
    )
)