# src/functions/wayburnseader3.jl
# Purpose: Implementation of the Wayburn Seader 3 test function.
# Global minimum: f(x*)=19.10588 at x*=[5.1469, 6.8396] (corrected via numerical optimization).
# Bounds: -500 ≤ x_i ≤ 500.

export WAYBURNSEADER3_FUNCTION, wayburnseader3, wayburnseader3_gradient

function wayburnseader3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader3 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    g = (x1 - 4)^2 + (x2 - 5)^2 - 4
    term1 = (2/3) * x1^3 - 8 * x1^2 + 33 * x1 - x1 * x2 + 5
    term2 = g^2
    return term1 + term2
end

function wayburnseader3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader3 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x[1], x[2]
    g = (x1 - 4)^2 + (x2 - 5)^2 - 4
    df1 = 2 * x1^2 - 16 * x1 + 33 - x2 + 4 * g * (x1 - 4)  # [RULE_TYPE_CONVERSION_MINIMAL]
    df2 = -x1 + 4 * g * (x2 - 5)
    return [df1, df2]  # [RULE_GRADTYPE]
end

const WAYBURNSEADER3_FUNCTION = TestFunction(
    wayburnseader3,
    wayburnseader3_gradient,
    Dict{Symbol, Any}(
        :name => "wayburnseader3",  # [RULE_NAME_CONSISTENCY]
        :description => "Wayburn Seader 3 Function; Properties based on Jamil & Yang (2013); originally from Wayburn & Seader (1987). Fixed n=2 (formula uses only first 2 variables; 'scalable' in source ignored per consistency rule). Corrected minimum from numerical optimization (source reports approximate 21.35 at [5.611,6.187], but actual global minimum is 19.10588 at [5.1469,6.8396]).",
        :math => raw"""f(\mathbf{x}) = \frac{2 x_1^3}{3} - 8 x_1^2 + 33 x_1 - x_1 x_2 + 5 + \left[ (x_1 - 4)^2 + (x_2 - 5)^2 - 4 \right]^2.""",
        :start => () -> [0.0, 0.0],
    :min_position => () -> [5.14689674946688, 6.83958974367702],
  :min_value => () -> 19.105879794568022,
   :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013)",  # [RULE_PROPERTIES_SOURCE]; correction noted in :description
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "wayburnseader3" == basename(@__FILE__)[1:end-3] "wayburnseader3: Dateiname mismatch!"