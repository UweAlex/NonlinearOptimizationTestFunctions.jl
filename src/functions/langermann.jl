# src/functions/langermann.jl
# Purpose: Implements the Langermann test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 12 September 2025

export LANGERMANN_FUNCTION, langermann, langermann_gradient

using LinearAlgebra
using ForwardDiff

"""
    langermann(x::AbstractVector)
Computes the Langermann function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function langermann(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
    any(isnan.(x)) && return eltype(x)(NaN)
    any(isinf.(x)) && return eltype(x)(Inf)
    a = [3, 5, 2, 1, 7]
    b = [5, 2, 1, 4, 9]
    c = [1, 2, 5, 2, 3]
    m = 5
    sum = zero(eltype(x))
    for i in 1:m
        dist = (x[1] - a[i])^2 + (x[2] - b[i])^2
        dist = min(dist, eltype(x)(1e308 / π))  # Avoid overflow in exp
        sum += c[i] * exp(-dist / π) * cos(π * dist)
    end
    return -sum
end

"""
    langermann_gradient(x::AbstractVector)
Computes the gradient of the Langermann function. Returns a vector of length 2.
"""
function langermann_gradient(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Langermann requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(eltype(x)(NaN), 2)
    any(isinf.(x)) && return fill(eltype(x)(Inf), 2)
    a = [3, 5, 2, 1, 7]
    b = [5, 2, 1, 4, 9]
    c = [1, 2, 5, 2, 3]
    m = 5
    grad = zeros(eltype(x), 2)
    for i in 1:m
        dist = (x[1] - a[i])^2 + (x[2] - b[i])^2
        dist = min(dist, eltype(x)(1e308 / π))  # Avoid overflow
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
        :start => () -> [5.0, 5.0],
        :min_position => () -> [2.002992119907532, 1.0060959403343601],
        :min_value => () -> -5.162126159963982,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "controversial", "continuous"]),
        :lb => () -> [0.0, 0.0],
        :ub => () -> [10.0, 10.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Langermann function: Multimodal, non-convex, non-separable test function with unevenly distributed local minima. Minimum at [2.002992119907532, 1.0060959403343601] with value -5.162126159963982, confirmed by high-precision calculations in Al-Roomi (2015) and verified via tf.f(tf.meta[:min_position]()) with atol=1e-6. Gradient norm at minimum is ~1.748e-9 within atol=0.01. Warning: Some sources (e.g., GlomPo, GEATbx) report a local minimum at approximately [2.002992, 1.006096] with value ≈-1.4, likely due to confusion with a local minimum or documentation error. See Al-Roomi (2015) for details.",
        :math => "-\\sum_{i=1}^m c_i \\exp \\left[-\\frac{1}{\\pi} \\sum_{j=1}^n (x_j - a_{ij})^2 \\right] \\cos \\left[ \\pi \\sum_{j=1}^n (x_j - a_{ij})^2 \\right]"
    )
)