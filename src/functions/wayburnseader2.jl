# src/functions/wayburnseader2.jl
# Purpose: Implementation of the Wayburn Seader 2 test function.
# Global minimum: f(x*)=0 at x*=(0.2,1) and (0.425,1).
# Bounds: -500 ≤ x_i ≤ 500.

export WAYBURNSEADER2_FUNCTION, wayburnseader2, wayburnseader2_gradient

function wayburnseader2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader2 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    a = x1 - T(0.3125)
    b = x2 - T(1.625)
    inner = T(1.613) - T(4) * a^2 - T(4) * b^2
    (inner^2) + (x2 - T(1))^2
end

function wayburnseader2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader2 requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1, x2 = x[1], x[2]
    a = x1 - T(0.3125)
    b = x2 - T(1.625)
    inner = T(1.613) - T(4) * a^2 - T(4) * b^2
    grad[1] = T(2) * inner * (-T(8) * a)
    grad[2] = T(2) * inner * (-T(8) * b) + T(2) * (x2 - T(1))
    grad
end

const WAYBURNSEADER2_FUNCTION = TestFunction(
    wayburnseader2,
    wayburnseader2_gradient,
    Dict{Symbol, Any}(
        :name => "wayburnseader2",  # [RULE_NAME_CONSISTENCY]
        :description => "Wayburn Seader 2 function; Properties based on Jamil & Yang (2013, p. 63); multiple global minima at (0.2,1) and (0.425,1); originally from Wayburn & Seader (1987). Formel only uses first 2 variables; marked as scalable in source but adapted to fixed n=2.",
        :math => raw"""f(\mathbf{x}) = \left[ 1.613 - 4(x_1 - 0.3125)^2 - 4(x_2 - 1.625)^2 \right]^2 + (x_2 - 1)^2.""",
        :start => () -> [-5.0, -5.0],
        :min_position => () -> [0.2, 1.0],  # Eine Position; multiple in description
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 63)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "wayburnseader2" == basename(@__FILE__)[1:end-3] "wayburnseader2: Dateiname mismatch!"