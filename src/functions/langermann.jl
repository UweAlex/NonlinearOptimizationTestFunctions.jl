# src/functions/langermann.jl
# Purpose: Implements the Langermann test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 20 July 2025

export LANGERMANN_FUNCTION, langermann, langermann_gradient

using LinearAlgebra
using ForwardDiff

"""
    langermann(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Langermann function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function langermann(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    a = [3, 5, 2, 1, 7]
    b = [5, 2, 1, 4, 9]
    c = [1, 2, 5, 2, 3]
    m = 5
    sum = zero(T)
    for i in 1:m
        dist = (x[1] - a[i])^2 + (x[2] - b[i])^2
        dist = min(dist, T(1e308 / π))  # Avoid overflow in exp
        sum += c[i] * exp(-dist / π) * cos(π * dist)
    end
    return -sum
end

"""
    langermann_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Langermann function. Returns a vector of length 2.
"""
function langermann_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    a = [3, 5, 2, 1, 7]
    b = [5, 2, 1, 4, 9]
    c = [1, 2, 5, 2, 3]
    m = 5
    grad = zeros(T, 2)
    for i in 1:m
        dist = (x[1] - a[i])^2 + (x[2] - b[i])^2
        dist = min(dist, T(1e308 / π))  # Avoid overflow
        exp_term = exp(-dist / π)
        cos_term = cos(π * dist)
        common = c[i] * exp_term * (2 / π * cos_term + 2 * π * sin(π * dist))
        grad[1] += common * (x[1] - a[i])
        grad[2] += common * (x[2] - b[i])
    end
    return grad
end

const LANGERMANN_FUNCTION = TestFunction(
    langermann,
    langermann_gradient,
    Dict(
        :name => "langermann",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
            [5.0, 5.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
            [2.002992119907532, 1.0060959403343601]
        end,
        :min_value => -5.162126159963982,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "controversial"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
            [10.0, 10.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Langermann function: Multimodal, non-convex, non-separable test function with unevenly distributed local minima. Minimum at [2.002992119907532, 1.0060959403343601] with value -5.162126159963982, confirmed by high-precision calculations (gradient norm ~1.748e-9). Gradient at minimum is near zero within atol=0.01. Gradient comparisons require atol=0.01 due to complex exponential and trigonometric terms. Warning: The global minimum is controversial; some sources (e.g., GlomPo, GEATbx) report a local minimum at approximately [2.002992, 1.006096] with value ≈-1.4, possibly due to different local minima or documentation error.",
        :math => "-\\sum_{i=1}^m c_i \\exp \\left[-\\frac{1}{\\pi} \\sum_{j=1}^n (x_j - a_{ij})^2 \\right] \\cos \\left[ \\pi \\sum_{j=1}^n (x_j - a_{ij})^2 \\right]"
    )
)