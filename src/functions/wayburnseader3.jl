# src/functions/wayburnseader3.jl
# Purpose: Implementation of the Wayburn Seader 3 test function.
# Global minimum: f(x*)=19.105879794568022 at x*=[5.14689674946688, 6.83958974367702].
# Bounds: -500 ≤ x_i ≤ 500.

export WAYBURNSEADER3_FUNCTION, wayburnseader3, wayburnseader3_gradient

function wayburnseader3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    x1, x2 = x[1], x[2]
    g = (x1 - 4.0)^2 + (x2 - 5.0)^2 - 4.0
    term1 = (2.0 / 3.0) * x1^3 - 8.0 * x1^2 + 33.0 * x1 - x1 * x2 + 5.0
    term2 = g^2
    term1 + term2
end

function wayburnseader3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    x1, x2 = x[1], x[2]
    g = (x1 - 4.0)^2 + (x2 - 5.0)^2 - 4.0
    grad[1] = 2.0 * x1^2 - 16.0 * x1 + 33.0 - x2 + 4.0 * g * (x1 - 4.0)
    grad[2] = -x1 + 4.0 * g * (x2 - 5.0)
    grad
end

const WAYBURNSEADER3_FUNCTION = TestFunction(
    wayburnseader3,
    wayburnseader3_gradient,
    Dict{Symbol, Any}(
        :name => "wayburnseader3",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Wayburn Seader 3 function. Properties based on Jamil & Yang (2013, p. 63); originally from Wayburn & Seader (1987). Marked as scalable in source, but formula only uses first 2 variables; adapted to fixed n=2. Minimum corrected via numerical optimization from source approximate 21.35 at (5.611,6.187) to exact 19.10588 at (5.147,6.840).",
        :math => raw"""f(\mathbf{x}) = \frac{2}{3} x_1^3 - 8 x_1^2 + 33 x_1 - x_1 x_2 + 5 + \left[ (x_1 - 4)^2 + (x_2 - 5)^2 - 4 \right]^2.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [5.14689674946688, 6.83958974367702],
        :min_value => () -> 19.105879794568022,
        :properties => ["bounded", "continuous", "controversial", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 63)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)

# Optional: Validierung beim Laden
