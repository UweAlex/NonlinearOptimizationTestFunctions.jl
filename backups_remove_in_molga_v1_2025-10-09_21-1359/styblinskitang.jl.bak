# src/functions/styblinskitang.jl
# Purpose: Implements the Styblinski-Tang test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 05 September 2025

export STYBLINSKITANG_FUNCTION, styblinskitang, styblinskitang_gradient

using LinearAlgebra
using ForwardDiff

"""
    styblinskitang(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Styblinski-Tang function value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function styblinskitang(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = zero(T)
    for i in 1:length(x)
        sum += x[i]^4 - 16 * x[i]^2 + 5 * x[i]
    end
    return sum / 2
end

"""
    styblinskitang_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Styblinski-Tang function. Returns a vector of length n.
"""
function styblinskitang_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    grad = zeros(T, n)
    for i in 1:n
        grad[i] = 2 * x[i]^3 - 16 * x[i] + 2.5
    end
    return grad
end

const STYBLINSKITANG_FUNCTION = TestFunction(
    styblinskitang,
    styblinskitang_gradient,
    Dict(
        :name => "styblinskitang",
        :start => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
            fill(-2.9035340276126953, n)
        end,
        :min_value => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
            -39.16616570377141 * n
        end,
        :properties => Set(["differentiable", "non-convex", "scalable", "multimodal", "bounded", "continuous"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
            fill(-5.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Styblinski-Tang requires at least 1 dimension"))
            fill(5.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Styblinski-Tang function: Multimodal, non-convex, scalable function with global minimum at approximately -39.16616570377141 * n.",
        :math => "\\frac{1}{2} \\sum_{i=1}^n (x_i^4 - 16 x_i^2 + 5 x_i)"
    )
)
