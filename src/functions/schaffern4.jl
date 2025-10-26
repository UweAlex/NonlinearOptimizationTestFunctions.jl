# src/functions/schaffern4.jl
# Purpose: Implements the Schaffer N.4 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 26, 2025

export SCHAFFERN4_FUNCTION, schaffern4, schaffern4_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Schaffer N.4 function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# The Schaffer N.4 function is defined as:
# f(x) = 0.5 + (cos²(sin(|x₁² - x₂²|)) - 0.5) / (1 + 0.001(x₁² + x₂²))²
#
# Reference: Al-Roomi (2015, Modified Schaffer's Function No. 04)
function schaffern4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern4 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    
    diff_sq_abs = abs(x1_sq - x2_sq)
    sin_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_diff)
    
    numerator = cos_sin^2 - 0.5  # [RULE_TYPE_CONVERSION_MINIMAL]
    denominator = (1 + 0.001 * (x1_sq + x2_sq))^2  # [RULE_TYPE_CONVERSION_MINIMAL]
    
    return 0.5 + numerator / denominator  # [RULE_TYPE_CONVERSION_MINIMAL]
end #function

# Computes the gradient of the Schaffer N.4 function. Returns a vector of length 2.
#
# Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
# Throws `DomainError` if the function is not differentiable at the given point (|x₁² - x₂²| ≈ 0).
function schaffern4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern4 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    x1_sq = x1^2
    x2_sq = x2^2
    sum_sq = x1_sq + x2_sq
    diff_sq = x1_sq - x2_sq
    
    # Prüfe Nicht-Differenzierbarkeit
    if abs(diff_sq) < 1e-10  # Numerische Toleranz
        throw(DomainError(x, "schaffern4 is not differentiable at |x₁² - x₂²| ≈ 0"))
    end #if
    
    sign_diff = diff_sq >= 0 ? one(T) : -one(T)  # [RULE_TYPE_CONVERSION_MINIMAL]
    
    diff_sq_abs = abs(diff_sq)
    sin_abs_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_abs_diff)
    cos_abs_diff = cos(diff_sq_abs)
    sin_sin = sin(sin_abs_diff)
    
    denom = 1 + 0.001 * sum_sq  # [RULE_TYPE_CONVERSION_MINIMAL]
    denom_sq = denom^2
    
    # Common terms
    numerator = cos_sin^2 - 0.5  # [RULE_TYPE_CONVERSION_MINIMAL]
    
    # Chain rule for the derivative:
    # d/dx₁ [cos²(sin(|x₁²-x₂²|))] = 2*cos(sin(|x₁²-x₂²|))*(-sin(sin(|x₁²-x₂²|)))*cos(|x₁²-x₂²|)*sign(x₁²-x₂²)*2*x₁
    cos_sin_term = -2 * cos_sin * sin_sin * cos_abs_diff
    
    # Derivatives of numerator
    d_num_dx1 = cos_sin_term * sign_diff * 2 * x1
    d_num_dx2 = cos_sin_term * sign_diff * (-2 * x2)
    
    # Derivatives of denominator
    d_denom_dx1 = 2 * denom * 0.001 * 2 * x1  # [RULE_TYPE_CONVERSION_MINIMAL]
    d_denom_dx2 = 2 * denom * 0.001 * 2 * x2  # [RULE_TYPE_CONVERSION_MINIMAL]
    
    # Apply quotient rule: (f/g)' = (f'*g - f*g')/g²
    denom_4th = denom_sq^2
    
    grad1 = (d_num_dx1 * denom_sq - numerator * d_denom_dx1) / denom_4th
    grad2 = (d_num_dx2 * denom_sq - numerator * d_denom_dx2) / denom_4th
    
    return [grad1, grad2]  # [RULE_GRADTYPE]
end #function

const SCHAFFERN4_FUNCTION = TestFunction(
    schaffern4,
    schaffern4_gradient,
    Dict(
        :name => "schaffern4",  # [RULE_NAME_CONSISTENCY]
        :description => "Modified Schaffer N.4 function: A multimodal function with global minimum at (0, 1.25313) and other equivalent points. Properties adapted from Al-Roomi (2015, Modified Schaffer's Function No. 04) for the variant with |x₁² - x₂²|; originally from Jamil & Yang (2013, p. 27) with sin(x₁ - x₂).",  # [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = 0.5 + \frac{\cos^2(\sin(|x_1^2 - x_2^2|)) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}""",
        :start => () -> [0.0, 1.253131828792882],
        :min_position => () -> [0.0, 1.253131828792882],
        :min_value => () -> 0.29257863203598033,
        :properties => ["bounded", "continuous", "multimodal", "non-convex", "non-separable", "partially differentiable"],  # Vector statt Set; nur VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Al-Roomi (2015, Modified Schaffer's Function No. 04)",  # [RULE_PROPERTIES_SOURCE] – direkte Quelle mit spezifischer Stelle
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "schaffern4" == basename(@__FILE__)[1:end-3] "schaffern4: Dateiname mismatch!"