# src/functions/shekel.jl
# Purpose: Implements the Shekel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 17 August 2025

export SHEKEL_FUNCTION, shekel, shekel_gradient

using LinearAlgebra
using ForwardDiff

"""
    shekel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Shekel function value at point `x`. Requires exactly 4 dimensions.
Returns `NaN` for inputs containing `NaN`, and a finite value for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function shekel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    m = 10
    a = [
        4.0 4.0 4.0 4.0;
        1.0 1.0 1.0 1.0;
        8.0 8.0 8.0 8.0;
        6.0 6.0 6.0 6.0;
        3.0 7.0 3.0 7.0;
        2.0 9.0 2.0 9.0;
        5.0 5.0 3.0 3.0;
        8.0 1.0 8.0 1.0;
        6.0 2.0 6.0 2.0;
        7.0 3.6 7.0 3.6
    ]
    c = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5]
    sum([1.0 / (dot(x .- a[i, :], x .- a[i, :]) + c[i]) for i in 1:m]) * (-1)
end

"""
    shekel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Shekel function. Returns a vector of length 4.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function shekel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return zeros(T, n)
    m = 10
    a = [
        4.0 4.0 4.0 4.0;
        1.0 1.0 1.0 1.0;
        8.0 8.0 8.0 8.0;
        6.0 6.0 6.0 6.0;
        3.0 7.0 3.0 7.0;
        2.0 9.0 2.0 9.0;
        5.0 5.0 3.0 3.0;
        8.0 1.0 8.0 1.0;
        6.0 2.0 6.0 2.0;
        7.0 3.6 7.0 3.6
    ]
    c = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5]
    grad = zeros(T, 4)
    for i in 1:m
        diff = x .- a[i, :]
        denom = dot(diff, diff) + c[i]
        grad .+= (2.0 * diff) / denom^2
    end
    return grad
end

const SHEKEL_FUNCTION = TestFunction(
    shekel,
    shekel_gradient,
    Dict(
        :name => "shekel",
        :start => (n::Int=4) -> begin
            n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
            fill(2.0, n)
        end,
        :min_position => (n::Int=4) -> begin
    n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
    [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956]
end,
       :min_value => -10.536409816692043,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "finite_at_inf","continuous"]),
        :lb => (n::Int=4) -> begin
            n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
            fill(0.0, n)
        end,
        :ub => (n::Int=4) -> begin
            n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
  :description => "Shekel function: Multimodal, finite at infinity, non-convex, non-separable, differentiable function defined for n=4, with multiple local minima and a global minimum at [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956].",
        :math => "f(x) = -\\sum_{i=1}^{10} \\frac{1}{\\sum_{j=1}^4 (x_j - a_{ij})^2 + c_i}"
    )
)