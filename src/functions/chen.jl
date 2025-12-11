# src/functions/chen.jl
# Purpose: Implements the Chen V test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 12 September 2025

export CHEN_FUNCTION, chen, chen_gradient

using LinearAlgebra
using ForwardDiff

"""
    chen(x::AbstractVector)
Computes the Chen V function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function chen(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Chen V requires exactly 2 dimensions"))
    any(isnan.(x)) && return eltype(x)(NaN)
    any(isinf.(x)) && return eltype(x)(Inf)
    
    x1, x2 = x[1], x[2]
    term1 = x1 - 0.4 * x2 - 0.1
    term2 = 2 * x1 + x2 - 1.5
    return -(0.001 / (0.000001 + term1^2) + 0.001 / (0.000001 + term2^2))
end

"""
    chen_gradient(x::AbstractVector)
Computes the gradient of the Chen V function. Returns a vector of length 2.
"""
function chen_gradient(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Chen V requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(eltype(x)(NaN), 2)
    any(isinf.(x)) && return fill(eltype(x)(Inf), 2)
    
    x1, x2 = x[1], x[2]
    term1 = x1 - 0.4 * x2 - 0.1
    term2 = 2 * x1 + x2 - 1.5
    denom1 = (0.000001 + term1^2)^2
    denom2 = (0.000001 + term2^2)^2
    grad_x1 = 0.002 * term1 / denom1 + 0.004 * term2 / denom2
    grad_x2 = -0.0008 * term1 / denom1 + 0.002 * term2 / denom2
    return [grad_x1, grad_x2]
end

const CHEN_FUNCTION = TestFunction(
    chen,
    chen_gradient,
    Dict(
        :name => "chen",
        :start => () -> [0.01, 0.01],
        :min_position => () -> [0.388888888888889, 0.722222222222222],
        :min_value => () -> -2000.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
        :description => "Chen V function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: -2000.0 at (0.388888888888889, 0.722222222222222). Bounds: [-500, 500]^2. Dimensions: n=2. Formulated as a minimum problem by negating the maximum problem from [Naser et al. (2024)] and [al-roomi.org], where f(0.388888888888889, 0.722222222222222) = 2000. [Jamil & Yang (2013): f32] reports a different function with minimum f(-0.3888889, 0.7222222) = -2000.",
        :math => "-\\left(\\frac{0.001}{0.000001 + (x_1 - 0.4 x_2 - 0.1)^2} + \\frac{0.001}{0.000001 + (2 x_1 + x_2 - 1.5)^2}\\right)",
        :reference => "[Jamil & Yang (2013): f32], [Naser et al. (2024)], [al-roomi.org]"
    )
)