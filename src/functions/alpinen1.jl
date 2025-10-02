# src/functions/alpinen1.jl
# Purpose: Implements the AlpineN1 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 28 August 2025

export ALPINEN1_FUNCTION, alpinen1, alpinen1_gradient

using LinearAlgebra
using ForwardDiff

"""
    alpinen1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the AlpineN1 function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty.
"""
function alpinen1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum(abs(xi * sin(xi) + 0.1 * xi) for xi in x)
end

"""
    alpinen1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the AlpineN1 function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or at non-differentiable points.
"""
function alpinen1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    for i in 1:n
        xi = x[i]
        term = xi * sin(xi) + 0.1 * xi
        if abs(term) < eps(T)
            throw(DomainError(x, "Gradient not defined at points where xi * sin(xi) + 0.1 * xi = 0"))
        end
        grad[i] = sign(term) * (sin(xi) + xi * cos(xi) + 0.1)
    end
    return grad
end

const ALPINEN1_FUNCTION = TestFunction(
    alpinen1,
    alpinen1_gradient,
    Dict(
        :name => "alpinen1",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("AlpineN1 requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("AlpineN1 requires at least 1 dimension"))
            zeros(n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["multimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("AlpineN1 requires at least 1 dimension"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("AlpineN1 requires at least 1 dimension"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "AlpineN1 function: Multimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: 0 at (0, ..., 0) and other points where xi * sin(xi) + 0.1 * xi = 0.",
        :math => "\\sum_{i=1}^n |x_i \\sin(x_i) + 0.1 x_i|"
    )
)
