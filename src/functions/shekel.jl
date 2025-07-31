# src/functions/shekel.jl
# Purpose: Implements the Shekel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 31 July 2025

export SHEKEL_FUNCTION, shekel, shekel_gradient

using LinearAlgebra
using ForwardDiff

"""
    shekel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Shekel function value at point `x`. Requires exactly 4 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function shekel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
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
"""
function shekel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
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
            [4.0, 4.0, 4.0, 4.0]
        end,
        :min_value => -10.536409825004505,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable"]),
        :lb => (n::Int=4) -> begin
            n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
            fill(0.0, n)
        end,
        :ub => (n::Int=4) -> begin
            n == 4 || throw(ArgumentError("Shekel requires exactly 4 dimensions"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Shekel function: Multimodal, non-convex, non-separable, differentiable function defined for n=4, with multiple local minima and a global minimum at [4.0, 4.0, 4.0, 4.0]. Note that the gradient at the minimum is non-zero due to the function's multimodal structure.",
        :math => "\\sum_{i=1}^{10} \\frac{1}{\\sum_{j=1}^4 (x_j - a_{ij})^2 + c_i}"
    )
)