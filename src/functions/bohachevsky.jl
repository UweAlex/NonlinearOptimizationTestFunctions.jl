# src/functions/bohachevsky.jl
# Purpose: Implements the Bohachevsky test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 02 August 2025

export BOHACHEVSKY_FUNCTION, bohachevsky, bohachevsky_gradient

using LinearAlgebra
using ForwardDiff

"""
    bohachevsky(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Bohachevsky function value at point `x`. Works for any dimension n ≥ 2.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function bohachevsky(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    sum = zero(T)
    for i in 1:(n-1)
        sum += x[i]^2 + 2 * x[i+1]^2 - 0.3 * cos(3 * π * x[i]) - 0.4 * cos(4 * π * x[i+1]) + 0.7
    end
    return sum
end

"""
    bohachevsky_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Bohachevsky function. Returns a vector of length n.
"""
function bohachevsky_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    grad = zeros(T, n)
    for i in 1:(n-1)
        grad[i] += 2 * x[i] + 0.3 * 3 * π * sin(3 * π * x[i])
        grad[i+1] += 4 * x[i+1] + 0.4 * 4 * π * sin(4 * π * x[i+1])
    end
    return grad
end

const BOHACHEVSKY_FUNCTION = TestFunction(
    bohachevsky,
    bohachevsky_gradient,
    Dict(
        :name => "bohachevsky",
        :start => (n::Int) -> begin
            n >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
            zeros(n)
        end,
        :min_value => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
            0.0
        end,
        :properties => Set(["differentiable", "multimodal", "non-convex", "scalable","bounded","continuous"]),
        :lb => (n::Int) -> begin
            n >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 2 || throw(ArgumentError("Bohachevsky requires at least 2 dimensions"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Bohachevsky function: Multimodal, non-convex, scalable function with global minimum at zero.",
        :math => "\\sum_{i=1}^{n-1} \\left[ x_i^2 + 2x_{i+1}^2 - 0.3 \\cos(3\\pi x_i) - 0.4 \\cos(4\\pi x_{i+1}) + 0.7 \\right]"
    )
)
