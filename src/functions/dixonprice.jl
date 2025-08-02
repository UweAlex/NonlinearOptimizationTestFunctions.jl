# src/functions/dixonprice.jl
# Purpose: Implements the Dixon-Price test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 02 August 2025

export DIXONPRICE_FUNCTION, dixonprice, dixonprice_gradient

using LinearAlgebra
using ForwardDiff

"""
    dixonprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Dixon-Price function value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function dixonprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    sum = (x[1] - 1)^2
    for i in 2:n
        sum += i * (2 * x[i]^2 - x[i-1])^2
    end
    return sum
end

"""
    dixonprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Dixon-Price function. Returns a vector of length n.
"""
function dixonprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    grad = zeros(T, n)
    grad[1] = 2 * (x[1] - 1)
    if n > 1
        grad[1] -= 4 * (2 * x[2]^2 - x[1])
        for i in 2:(n-1)
            grad[i] = 8 * i * (2 * x[i]^2 - x[i-1]) * x[i] - 2 * (i + 1) * (2 * x[i+1]^2 - x[i])
        end
        grad[n] = 8 * n * (2 * x[n]^2 - x[n-1]) * x[n]
    end
    return grad
end

const DIXONPRICE_FUNCTION = TestFunction(
    dixonprice,
    dixonprice_gradient,
    Dict(
        :name => "dixonprice",
        :start => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
            [2^(-(2^i - 2) / 2^i) for i in 1:n]
        end,
        :min_value => 0.0,
        :properties => Set(["differentiable", "non-convex", "scalable", "unimodal"]),
        :lb => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Dixon-Price requires at least 1 dimension"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Dixon-Price function: Unimodal, non-convex, scalable function with global minimum at zero.",
        :math => "(x_1 - 1)^2 + \\sum_{i=2}^n i (2 x_i^2 - x_{i-1})^2"
    )
)