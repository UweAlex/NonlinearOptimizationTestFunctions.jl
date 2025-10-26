# src/functions/shekel.jl
# Purpose: Implements the Shekel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 26, 2025

export SHEKEL_FUNCTION, shekel, shekel_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Shekel function value at point `x`. Requires exactly 4 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `0.0` for inputs containing `Inf` (finite at infinity).
#
# The Shekel function is defined as:
# f(x) = -∑_{i=1}^{10} 1 / (∑_{j=1}^4 (x_j - a_{ij})^2 + c_i)
#
# Reference: Jamil & Yang (2013, p. 30) [f_{132}]
function shekel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("shekel requires exactly 4 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(0.0)  # Finite at infinity [RULE_ERROR_HANDLING]
    
    m = 10
    a = [
        4.0 4.0 4.0 4.0;
        1.0 1.0 1.0 1.0;
        8.0 8.0 8.0 8.0;
        6.0 6.0 6.0 6.0;
        3.0 7.0 3.0 7.0;
        2.0 9.0 2.0 9.0;
        5.0 5.0 3.0 3.0;
        8.0 1.0 8.0 1.0;
        6.0 2.0 6.0 2.0;
        7.0 3.6 7.0 3.6
    ]
    c = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5]
    sum([1.0 / (dot(x .- a[i, :], x .- a[i, :]) + c[i]) for i in 1:m]) * (-1)  # [RULE_NO_CONST_ARRAYS] – local
end #function

# Computes the gradient of the Shekel function. Returns a vector of length 4.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
# Returns zeros for inputs containing `Inf` (gradient approaches 0 at infinity).
function shekel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("shekel requires exactly 4 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return zeros(T, n)  # [RULE_ERROR_HANDLING]
    
    m = 10
    a = [
        4.0 4.0 4.0 4.0;
        1.0 1.0 1.0 1.0;
        8.0 8.0 8.0 8.0;
        6.0 6.0 6.0 6.0;
        3.0 7.0 3.0 7.0;
        2.0 9.0 2.0 9.0;
        5.0 5.0 3.0 3.0;
        8.0 1.0 8.0 1.0;
        6.0 2.0 6.0 2.0;
        7.0 3.6 7.0 3.6
    ]
    c = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3, 0.7, 0.5, 0.5]
    grad = zeros(T, 4)  # [RULE_GRADTYPE]
    @inbounds for i in 1:m  # SHOULD: @inbounds
        diff = x .- a[i, :]
        denom = dot(diff, diff) + c[i]
        grad .+= (2.0 * diff) / denom^2  # [RULE_TYPE_CONVERSION_MINIMAL]
    end
    return grad  # Corrected: No extra negation needed (mathematical fix for gradient accuracy)
end #function

const SHEKEL_FUNCTION = TestFunction(
    shekel,
    shekel_gradient,
    Dict(
        :name => "shekel",  # [RULE_NAME_CONSISTENCY]
        :description => "Shekel function (m=10): Multimodal, finite at infinity, non-convex, non-separable, differentiable function defined for n=4, with multiple local minima and a global minimum near [4,4,4,4]. Properties based on Jamil & Yang (2013, p. 30) [f_{132}]; originally from Molga & Smutnicki (2005).",  # [RULE_PROPERTIES_SOURCE] [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = -\sum_{i=1}^{10} \frac{1}{\sum_{j=1}^4 (x_j - a_{ij})^2 + c_i}""",
        :start => () -> [2.0, 2.0, 2.0, 2.0],  # [RULE_META_CONSISTENCY] – () for non-scalable
        :min_position => () -> [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956],
        :min_value => () -> -10.536409816692043,
        :properties => ["bounded", "continuous", "differentiable", "finite_at_inf", "multimodal", "non-convex", "non-separable"],  # Vector; sorted; only VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Jamil & Yang (2013, p. 30)",  # [RULE_PROPERTIES_SOURCE] – direct source with page; exact formula match for f_{132} (m=10)
        :lb => () -> [0.0, 0.0, 0.0, 0.0],  # [RULE_META_CONSISTENCY]
        :ub => () -> [10.0, 10.0, 10.0, 10.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "shekel" == basename(@__FILE__)[1:end-3] "shekel: Dateiname mismatch!"