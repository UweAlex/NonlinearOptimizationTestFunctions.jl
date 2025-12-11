# src/functions/ursem1.jl

# Purpose: Implementation of the Ursem 1 test function.
# Global minimum: f(x*)=-4.816814063734245 at x*=[1.697137, 0.0].
# Bounds: -2.5 ≤ x_1 ≤ 3, -2 ≤ x_2 ≤ 2.

export URSEM1_FUNCTION, ursem1, ursem1_gradient

function ursem1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem1 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    -sin(2 * x1 - 0.5 * π) - 3 * cos(x2) - 0.5 * x1  # No redundant T() conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

function ursem1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem1 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1, x2 = x
    grad[1] = -2 * cos(2 * x1 - 0.5 * π) - 0.5
    grad[2] = 3 * sin(x2)
    grad
end

const URSEM1_FUNCTION = TestFunction(
    ursem1,
    ursem1_gradient,
    Dict{Symbol, Any}(
        :name => "ursem1",  # [RULE_NAME_CONSISTENCY]
        :description => "Implementation of the Ursem 1 test function. Properties based on Jamil & Yang (2013, p. 36); originally from Rönkkönen (2009). Single global minimum.",
        :math => raw"""f(\mathbf{x}) = -\sin(2x_1 - 0.5\pi) - 3\cos(x_2) - 0.5x_1.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.697137, 0.0],
        :min_value => () -> -4.816814063734245,  # Updated to match exact evaluation at min_position [RULE_MIN_VALUE_INDEPENDENT]
        :properties => ["bounded", "continuous", "differentiable", "separable", "unimodal"],  # From source; all in VALID_PROPERTIES
        :source => "Jamil & Yang (2013, p. 36)",  # [RULE_PROPERTIES_SOURCE]
        :lb => () -> [-2.5, -2.0],
        :ub => () -> [3.0, 2.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
