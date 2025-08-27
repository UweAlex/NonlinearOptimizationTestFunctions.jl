# src/functions/mishrabird.jl
# Purpose: Implements the MishraBird test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export MISHRAbird_FUNCTION, mishrabird, mishrabird_gradient

using LinearAlgebra
using ForwardDiff

"""
    mishrabird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the MishraBird function value at point `x`. Requires 2 dimension(s).
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function mishrabird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("MishraBird requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    
    # Although often defined with the constraint (x+5)^2 + (y+5)^2 < 25,
    # this implementation is unconstrained as per the library's focus.
    term1 = sin(x2) * exp((1 - cos(x1))^2)
    term2 = cos(x1) * exp((1 - sin(x2))^2)
    term3 = (x1 - x2)^2
    
    return term1 + term2 + term3
end

"""
    mishrabird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the MishraBird function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function mishrabird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("MishraBird requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x[1], x[2]
    
    exp1 = exp((1 - cos(x1))^2)
    exp2 = exp((1 - sin(x2))^2)
    
    grad1 = sin(x2) * exp1 * 2 * (1 - cos(x1)) * sin(x1) - sin(x1) * exp2 + 2 * (x1 - x2)
    grad2 = cos(x2) * exp1 - cos(x1) * exp2 * 2 * (1 - sin(x2)) * cos(x2) - 2 * (x1 - x2)
    
    return [grad1, grad2]
end

const MISHRAbird_FUNCTION = TestFunction(
    mishrabird,
    mishrabird_gradient,
    Dict(
        :name => "mishrabird",
        :start => () -> [-1.0, -1.0],
        :min_position => () -> [-3.1302468, -1.5821422], # One of the two global minima
        :min_value => -106.764537,
        :properties => Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded","continuous"]),
        :lb => () -> [-10.0, -6.5],
        :ub => () -> [0.0, 0.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Mishra's Bird function is a multimodal, non-separable function with two known global minima. It is often cited with the constraint (x+5)^2+(y+5)^2 < 25, but this implementation is unconstrained.",
        :math => "f(x, y) = \\sin(y) e^{(1 - \\cos(x))^2} + \\cos(x) e^{(1 - \\sin(y))^2} + (x - y)^2"
    )
)