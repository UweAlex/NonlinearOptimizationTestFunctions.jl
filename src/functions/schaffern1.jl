# src/functions/schaffern1.jl
# Purpose: Implements the SchafferN1 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export SCHAFFERN1_FUNCTION, schaffern1, schaffern1_gradient

using LinearAlgebra
using ForwardDiff

"""
    schaffern1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the SchafferN1 function value at point `x`. Requires 2 dimension(s).
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function schaffern1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("SchafferN1 requires exactly 2 dimensions")) # [cite: 101]
    any(isnan.(x)) && return T(NaN)
    # For Inf input, the denominator grows faster, so the fraction goes to 0, result is 0.5
    any(isinf.(x)) && return T(0.5)
    
    r_sq = x[1]^2 + x[2]^2
    
    numerator = sin(sqrt(r_sq))^2 - 0.5
    denominator = (1 + 0.001 * r_sq)^2
    
    return 0.5 + numerator / denominator
end

"""
    schaffern1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the SchafferN1 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function schaffern1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("SchafferN1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(0.0), n)
    
    x1, x2 = x[1], x[2]
    r_sq = x1^2 + x2^2
    
    if r_sq == 0
        return [T(0.0), T(0.0)]
    end
    
    r = sqrt(r_sq)
    common_term_denom = (1 + 0.001 * r_sq)^3
    
    term1 = (sin(2*r) / r) * (1 + 0.001 * r_sq)
    term2 = 0.004 * (sin(r)^2 - 0.5)
    
    common_multiplier = (term1 - term2) / common_term_denom
    
    grad1 = x1 * common_multiplier
    grad2 = x2 * common_multiplier
    
    return [grad1, grad2]
end

const SCHAFFERN1_FUNCTION = TestFunction(
    schaffern1,
    schaffern1_gradient,
    Dict(
        :name => "schaffern1",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0], # [cite: 101]
        :min_value => 0.0, # [cite: 101]
        :properties => Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded","continuous"]), # [cite: 100]
        :lb => () -> [-100.0, -100.0], # [cite: 101]
        :ub => () -> [100.0, 100.0], # [cite: 101]
        :in_molga_smutnicki_2005 => false,
        :description => "Schaffer N1 is a highly multimodal, non-separable function with a global minimum at the center of its domain.",
        :math => "f(x, y) = 0.5 + \\frac{\\sin^2(\\sqrt{x^2 + y^2}) - 0.5}{(1 + 0.001(x^2 + y^2))^2}"
    )
)