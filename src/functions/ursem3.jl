# ursem3.jl
# Purpose: Implementation of the Ursem 3 test function.
# Global minimum: f(x*)=-2.5 at x*=[0.0, 0.0].
# Bounds: -2 ≤ x_1 ≤ 2, -1.5 ≤ x_2 ≤ 1.5.

export URSEM3_FUNCTION, ursem3, ursem3_gradient

function ursem3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem3 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    abs1 = abs(x1)
    abs2 = abs(x2)
    p = (3 - abs1) / 2
    q = (2 - abs2) / 2
    s = (2 - abs1) / 2
    term1 = p * q * sin(2.2 * π * x1 + 0.5 * π)
    term2 = s * q * sin(0.5 * π * x2^2 + 0.5 * π)
    -term1 - term2  # No redundant T() conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

function ursem3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem3 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1, x2 = x
    abs1 = abs(x1)
    abs2 = abs(x2)
    p = (3 - abs1) / 2
    s = (2 - abs1) / 2
    q = (2 - abs2) / 2
    sin_r = sin(2.2 * π * x1 + 0.5 * π)
    cos_r = cos(2.2 * π * x1 + 0.5 * π)
    sin_u = sin(0.5 * π * x2^2 + 0.5 * π)
    cos_u = cos(0.5 * π * x2^2 + 0.5 * π)
    dr_dx1 = 2.2 * π
    du_dx2 = π * x2
    dp_dx1 = -0.5 * sign(x1)
    ds_dx1 = -0.5 * sign(x1)
    dq_dx2 = -0.5 * sign(x2)
    
    grad[1] = - (dp_dx1 * q * sin_r + p * q * cos_r * dr_dx1 + ds_dx1 * q * sin_u)
    grad[2] = - (p * dq_dx2 * sin_r + s * dq_dx2 * sin_u + s * q * cos_u * du_dx2)
    grad
end

const URSEM3_FUNCTION = TestFunction(
    ursem3,
    ursem3_gradient,
    Dict{Symbol, Any}(
        :name => "ursem3",  # [RULE_NAME_CONSISTENCY]
        :description => "Implementation of the Ursem 3 test function. Properties based on Jamil & Yang (2013, p. 36); formula and minimum adapted from Al-Roomi (2015) to match reported global minimum of -2.5 (Jamil & Yang transcription appears erroneous); originally from Rönkkönen (2009). Contains absolute value terms.",
        :math => raw"""f(\mathbf{x}) = -\frac{3 - |x_1|}{2} \cdot \frac{2 - |x_2|}{2} \cdot \sin(2.2\pi x_1 + 0.5\pi) - \frac{2 - |x_1|}{2} \cdot \frac{2 - |x_2|}{2} \cdot \sin(0.5\pi x_2^2 + 0.5\pi).""",
        :start => () -> [-1.0, -0.5],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> -2.5,  # Exact value [RULE_MIN_VALUE_INDEPENDENT]
        :properties => ["bounded", "continuous", "multimodal", "non-separable", "partially differentiable"],  # From source + abs terms; all in VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Jamil & Yang (2013, p. 36)",  # Direct for properties; formula consistency noted in description [RULE_SOURCE_FORMULA_CONSISTENCY]
        :lb => () -> [-2.0, -1.5],
        :ub => () -> [2.0, 1.5],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
