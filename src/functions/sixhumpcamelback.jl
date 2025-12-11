# src/functions/sixhumpcamelback.jl
# Purpose: Implements the Six-Hump Camelback test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 26, 2025

export SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback, sixhumpcamelback_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Six-Hump Camelback function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# The Six-Hump Camelback function is defined as:
# f(x) = (4 - 2.1 x₁² + x₁⁴/3) x₁² + x₁ x₂ + (-4 + 4 x₂²) x₂²
#
# Reference: Jamil & Yang (2013, p. 10) [f_{30}]
function sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("sixhumpcamelback requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    term1 = (4.0 - 2.1 * x1^2 + x1^4 / 3.0) * x1^2  # [RULE_TYPE_CONVERSION_MINIMAL]
    term2 = x1 * x2
    term3 = (-4.0 + 4.0 * x2^2) * x2^2  # [RULE_TYPE_CONVERSION_MINIMAL]
    return term1 + term2 + term3
end #function

# Computes the gradient of the Six-Hump Camelback function. Returns a vector of length 2.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
# Returns NaN-vector for NaN-inputs and Inf-vector for Inf-inputs.
function sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("sixhumpcamelback requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    grad_x1 = 8.0 * x1 - 8.4 * x1^3 + 2.0 * x1^5 + x2  # [RULE_TYPE_CONVERSION_MINIMAL]
    grad_x2 = x1 - 8.0 * x2 + 16.0 * x2^3  # [RULE_TYPE_CONVERSION_MINIMAL]
    return [grad_x1, grad_x2]  # [RULE_GRADTYPE]
end #function

const SIXHUMPCAMELBACK_FUNCTION = TestFunction(
    sixhumpcamelback,
    sixhumpcamelback_gradient,
    Dict(
        :name => "sixhumpcamelback",  # [RULE_NAME_CONSISTENCY]
        :description => "Six-Hump Camelback function: A multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with six local minima and two equivalent global minima at (±0.089842, ∓0.712656) with value -1.031628. Properties based on Jamil & Yang (2013, p. 10) [f_{30}]; originally from Dixon & Szegő (1978). Bounds: [-3,3] x [-2,2].",  # [RULE_PROPERTIES_SOURCE] [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = \left(4 - 2.1 x_1^2 + \frac{x_1^4}{3}\right) x_1^2 + x_1 x_2 + (-4 + 4 x_2^2) x_2^2""",
        :start => () -> [0.0, 0.0],  # [RULE_META_CONSISTENCY]
        :min_position => () -> [0.08984201368301331, -0.7126564032704135],  # One global min; other symmetric [RULE_META_CONSISTENCY]
        :min_value => () -> -1.031628453489877,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],  # Vector; sorted; only VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Jamil & Yang (2013, p. 10)",  # [RULE_PROPERTIES_SOURCE] – direct source with page; exact formula match for f_{30}
        :lb => () -> [-3.0, -2.0],  # Corrected per sources [RULE_META_CONSISTENCY]
        :ub => () -> [3.0, 2.0]
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
