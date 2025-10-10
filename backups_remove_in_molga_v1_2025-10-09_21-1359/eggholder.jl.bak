# src/functions/eggholder.jl
# Purpose: Implements the Eggholder test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 12 September 2025

export EGGHOLDER_FUNCTION, eggholder, eggholder_gradient

using LinearAlgebra
using ForwardDiff

"""
    eggholder(x::AbstractVector)
Computes the Eggholder function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function eggholder(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return eltype(x)(NaN)
    any(isinf.(x)) && return eltype(x)(Inf)
    
    x1, x2 = x
    a = x2 + x1/2 + 47
    b = x1 - (x2 + 47)
    return - (x2 + 47) * sin(sqrt(abs(a))) - x1 * sin(sqrt(abs(b)))
end

"""
    eggholder_gradient(x::AbstractVector)
Computes the gradient of the Eggholder function. Returns a vector of length 2.
"""
function eggholder_gradient(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) == 2 || throw(ArgumentError("Eggholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(eltype(x)(NaN), 2)
    any(isinf.(x)) && return fill(eltype(x)(Inf), 2)
    
    x1, x2 = x
    a = x2 + x1/2 + 47
    b = x1 - (x2 + 47)
    sqrt_a = sqrt(abs(a))
    sqrt_b = sqrt(abs(b))
    sign_a = a >= 0 ? one(eltype(x)) : -one(eltype(x))
    sign_b = b >= 0 ? one(eltype(x)) : -one(eltype(x))
    grad_x1 = -sin(sqrt_b) - (x2 + 47) * cos(sqrt_a) * sign_a / (4 * sqrt_a) - x1 * cos(sqrt_b) * sign_b / (2 * sqrt_b)
    grad_x2 = -sin(sqrt_a) - (x2 + 47) * cos(sqrt_a) * sign_a / (2 * sqrt_a) + x1 * cos(sqrt_b) * sign_b / (2 * sqrt_b)
    return [grad_x1, grad_x2]
end

const EGGHOLDER_FUNCTION = TestFunction(
    eggholder,
    eggholder_gradient,
    Dict(
        :name => "eggholder",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [512.0, 404.2318058008512],
        :min_value => () -> -959.6406627208506 ,
        :properties => Set(["multimodal", "differentiable", "non-convex", "non-separable", "bounded", "continuous"]),
        :lb => () -> [-512.0, -512.0],
        :ub => () -> [512.0, 512.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Eggholder function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous test function with a global minimum of -959.6406627208506 at [512.0, 404.2318058008512]. Bounds: [-512, 512]^2. Dimensions: n=2. Used for benchmarking nonlinear optimization algorithms due to its many local minima. See [Jamil & Yang (2013)] for details.",
        :math => "- (x_2 + 47) \\sin\\left(\\sqrt{\\left|x_2 + \\frac{x_1}{2} + 47\\right|}\\right) - x_1 \\sin\\left(\\sqrt{\\left|x_1 - (x_2 + 47)\\right|}\\right)",
        :reference => "[Jamil & Yang (2013)]"
    )
)