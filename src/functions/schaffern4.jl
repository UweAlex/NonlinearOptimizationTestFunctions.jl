# src/functions/schaffern4.jl
# Purpose: Implements the Schaffer N.4 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 03, 2025

export SCHAFFERN4_FUNCTION, schaffern4, schaffern4_gradient

using LinearAlgebra
using ForwardDiff

"""
    schaffern4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the Schaffer N.4 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.

The Schaffer N.4 function is defined as:
f(x) = 0.5 + (cos²(sin(|x₁² - x₂²|)) - 0.5) / (1 + 0.001(x₁² + x₂²))²

Reference: Jamil & Yang (2013): f115
"""
function schaffern4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Schaffer N.4 requires exactly 2 dimensions"))
    
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    
    diff_sq_abs = abs(x1_sq - x2_sq)
    sin_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_diff)
    
    numerator = cos_sin^2 - T(0.5)
    denominator = (1 + T(0.001) * (x1_sq + x2_sq))^2
    
    return T(0.5) + numerator / denominator
end

"""
    schaffern4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the gradient of the Schaffer N.4 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
Throws `DomainError` if the function is not differentiable at the given point (|x₁² - x₂²| ≈ 0).
"""
function schaffern4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Schaffer N.4 requires exactly 2 dimensions"))
    
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    sum_sq = x1_sq + x2_sq
    diff_sq = x1_sq - x2_sq
    
    # Prüfe Nicht-Differenzierbarkeit
    if abs(diff_sq) < 1e-10  # Numerische Toleranz
        throw(DomainError(x, "Schaffer N.4 is not differentiable at |x₁² - x₂²| ≈ 0"))
    end
    
    sign_diff = diff_sq >= 0 ? T(1) : T(-1)
    
    diff_sq_abs = abs(diff_sq)
    sin_abs_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_abs_diff)
    cos_abs_diff = cos(diff_sq_abs)
    sin_sin = sin(sin_abs_diff)
    
    denom = 1 + T(0.001) * sum_sq
    denom_sq = denom^2
    
    # Common terms
    numerator = cos_sin^2 - T(0.5)
    
    # Chain rule for the derivative:
    # d/dx₁ [cos²(sin(|x₁²-x₂²|))] = 2*cos(sin(|x₁²-x₂²|))*(-sin(sin(|x₁²-x₂²|)))*cos(|x₁²-x₂²|)*sign(x₁²-x₂²)*2*x₁
    cos_sin_term = -2 * cos_sin * sin_sin * cos_abs_diff
    
    # Derivatives of numerator
    d_num_dx1 = cos_sin_term * sign_diff * 2 * x1
    d_num_dx2 = cos_sin_term * sign_diff * (-2 * x2)
    
    # Derivatives of denominator
    d_denom_dx1 = 2 * denom * T(0.001) * 2 * x1
    d_denom_dx2 = 2 * denom * T(0.001) * 2 * x2
    
    # Apply quotient rule: (f/g)' = (f'*g - f*g')/g²
    denom_4th = denom_sq^2
    
    grad1 = (d_num_dx1 * denom_sq - numerator * d_denom_dx1) / denom_4th
    grad2 = (d_num_dx2 * denom_sq - numerator * d_denom_dx2) / denom_4th
    
    return [grad1, grad2]
end

const SCHAFFERN4_FUNCTION = TestFunction(
    schaffern4,
    schaffern4_gradient,
    Dict(
        :name => "schaffern4",
        :start => () -> [0.0, 1.253131828792882],
        :min_position => () -> [0.0, 1.253131828792882],
        :min_value => 0.292578632035980,
        :properties => Set(["partially differentiable", "multimodal", "non-convex", "non-separable", "bounded", "continuous"]),
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Schaffer N.4 function: A multimodal function with global minimum at (0, 1.25313) and other equivalent points.",
        :math => "f(x) = 0.5 + \\frac{\\cos^2(\\sin(|x_1^2 - x_2^2|)) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}"
    )
)