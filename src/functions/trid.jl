# src/functions/trid.jl
# Purpose: Implements the Trid test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 24 August 2025

export TRID_FUNCTION, trid, trid_gradient

using LinearAlgebra
using ForwardDiff

"""
    trid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Trid function value at point `x`. Requires at least 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has fewer than 2 dimensions.
"""
function trid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum1 = sum((x[i] - 1)^2 for i in 1:n)
    sum2 = sum(x[i] * x[i-1] for i in 2:n)
    return sum1 - sum2
end

"""
    trid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Trid function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has fewer than 2 dimensions.
"""
function trid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    grad[1] = 2 * (x[1] - 1) - x[2]
    for i in 2:n-1
        grad[i] = 2 * (x[i] - 1) - x[i-1] - x[i+1]
    end
    grad[n] = 2 * (x[n] - 1) - x[n-1]
    return grad
end

const TRID_FUNCTION = TestFunction(
    trid,
    trid_gradient,
    Dict(
        :name => "trid",
        :start => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
            zeros(n)
        end,
        :min_position => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
            [i * (n + 1 - i) for i in 1:n]
        end,
        :min_value => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
            -n * (n + 4) * (n - 1) / 6
        end,
        :properties => Set(["unimodal", "convex", "non-separable", "differentiable", "scalable","bounded","continuous"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
            fill(-n^2, n)
        end,
        :ub => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Trid requires at least 2 dimension(s)"))
            fill(n^2, n)
        end,
        :description => "Trid function: Unimodal, convex, non-separable, differentiable, scalable test function with a single global minimum, suitable for testing optimization algorithms on non-separable problems.",
        :math => "\\sum_{i=1}^n (x_i - 1)^2 - \\sum_{i=2}^n x_i x_{i-1}"
    )
)
