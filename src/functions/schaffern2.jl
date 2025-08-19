# src/functions/schaffern2.jl
# Purpose: Implements the Schaffer N.2 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 19 August 2025

export SCHAFFERN2_FUNCTION, schaffern2, schaffern2_gradient

using LinearAlgebra
using ForwardDiff

"""
    schaffern2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the Schaffer N.2 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.

The Schaffer N.2 function is defined as:
f(x) = 0.5 + (sin²(x₁² - x₂²) - 0.5) / (1 + 0.001(x₁² + x₂²))²

Reference: Jamil & Yang (2013): f113
"""
function schaffern2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
    
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    
    numerator = sin(x1_sq - x2_sq)^2 - T(0.5)
    denominator = (1 + T(0.001) * (x1_sq + x2_sq))^2
    
    return T(0.5) + numerator / denominator
end

"""
    schaffern2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the gradient of the Schaffer N.2 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function schaffern2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
    
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    sum_sq = x1_sq + x2_sq
    diff_sq = x1_sq - x2_sq
    
    sin_diff = sin(diff_sq)
    cos_diff = cos(diff_sq)
    denom = 1 + T(0.001) * sum_sq
    denom_sq = denom^2
    
    # Common terms
    numerator = sin_diff^2 - T(0.5)
    
    # Partial derivatives
    # ∂f/∂x₁ = [2*sin(x₁²-x₂²)*cos(x₁²-x₂²)*2*x₁*(1+0.001*(x₁²+x₂²))² - (sin²(x₁²-x₂²)-0.5)*2*(1+0.001*(x₁²+x₂²))*0.001*2*x₁] / (1+0.001*(x₁²+x₂²))⁴
    sin_cos_term = 2 * sin_diff * cos_diff
    
    grad1_num = sin_cos_term * 2 * x1 * denom_sq - numerator * 2 * denom * T(0.001) * 2 * x1
    grad2_num = sin_cos_term * (-2 * x2) * denom_sq - numerator * 2 * denom * T(0.001) * 2 * x2
    
    denom_4th = denom_sq^2
    
    return [grad1_num / denom_4th, grad2_num / denom_4th]
end

const SCHAFFERN2_FUNCTION = TestFunction(
    schaffern2,
    schaffern2_gradient,
    Dict(
        :name => "schaffern2",
        :start => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
            [-100.0, -100.0]
        end,
        :ub => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Schaffer N.2 requires exactly 2 dimensions"))
            [100.0, 100.0]
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Schaffer N.2 function: A multimodal function with a global minimum at the origin and many local minima.",
        :math => "f(x) = 0.5 + \\frac{\\sin^2(x_1^2 - x_2^2) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}"
    )
)