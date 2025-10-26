# src/functions/sineenvelope.jl
# Purpose: Implements the Sine Envelope test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 26, 2025

export SINEENVELOPE_FUNCTION, sineenvelope, sineenvelope_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Sine Envelope function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# The Sine Envelope function is defined as:
# f(x) = -0.5 + (sin²(√(x₁² + x₂²)) - 0.5) / (1 + 0.001 (x₁² + x₂²))²
#
# Reference: Molga & Smutnicki (2005)
function sineenvelope(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("sineenvelope requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    r = sqrt(x[1]^2 + x[2]^2)
    -0.5 + (sin(r)^2 - 0.5) / (1 + 0.001 * r^2)^2  # [RULE_TYPE_CONVERSION_MINIMAL]
end #function

# Computes the gradient of the Sine Envelope function. Returns a vector of length 2.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
# Returns NaN-vector for NaN-inputs and Inf-vector for Inf-inputs.
function sineenvelope_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("sineenvelope requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    r2 = x[1]^2 + x[2]^2
    r = sqrt(r2)
    if r == 0
        return zeros(T, 2)  # [RULE_GRADTYPE]
    end
    sin_r = sin(r)
    cos_r = cos(r)
    denom = (1 + 0.001 * r2)^3
    num = 2 * sin_r * cos_r * (1 + 0.001 * r2) - 0.004 * r * (sin_r^2 - 0.5)
    factor = num / denom / r
    return [x[1] * factor, x[2] * factor]  # [RULE_GRADTYPE]
end #function

const SINEENVELOPE_FUNCTION = TestFunction(
    sineenvelope,
    sineenvelope_gradient,
    Dict(
        :name => "sineenvelope",  # [RULE_NAME_CONSISTENCY]
        :description => "Sine Envelope function: A multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with global minimum at (0,0). Properties based on Molga & Smutnicki (2005); also in Gaviano et al. (2003).",  # [RULE_PROPERTIES_SOURCE] [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = -0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}""",
        :start => () -> [1.0, 1.0],  # [RULE_META_CONSISTENCY] – () for non-scalable
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> -1.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],  # Vector; sorted; only VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Molga & Smutnicki (2005)",  # [RULE_PROPERTIES_SOURCE] – direct source (no page, as standard ref); exact formula match
        :lb => () -> [-100.0, -100.0],  # [RULE_META_CONSISTENCY]
        :ub => () -> [100.0, 100.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "sineenvelope" == basename(@__FILE__)[1:end-3] "sineenvelope: Dateiname mismatch!"