# src/functions/zirilli_aluffipentini.jl
# Purpose: Implementation of the Zirilli or Aluffi-Pentini’s test function.
# Global minimum: f(x*)=-0.3523 at x*=(-1.0465, 0.0).
# Bounds: -10 ≤ x_i ≤ 10.

export ZIRILLI_ALUFFIPENTINI_FUNCTION, zirilli_aluffipentini, zirilli_aluffipentini_gradient

function zirilli_aluffipentini(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("zirilli_aluffipentini requires exactly 2 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    # Local computation [RULE_NO_CONST_ARRAYS]
    x1 = x[1]
    x2 = x[2]
    T(0.25) * x1^4 - T(0.5) * x1^2 + T(0.1) * x1 + T(0.5) * x2^2  # [RULE_TYPE_CONVERSION_MINIMAL]
end

function zirilli_aluffipentini_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("zirilli_aluffipentini requires exactly 2 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1 = x[1]
    x2 = x[2]
    grad[1] = x1^3 - x1 + T(0.1)  # ∂f/∂x1
    grad[2] = x2  # ∂f/∂x2
    grad
end

const ZIRILLI_ALUFFIPENTINI_FUNCTION = TestFunction(
    zirilli_aluffipentini,
    zirilli_aluffipentini_gradient,
    Dict{Symbol, Any}(
        :name => "zirilli_aluffipentini",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Zirilli or Aluffi-Pentini’s function; Properties based on Jamil & Yang (2013, p. 40); non-scalable (fixed n=2); originally from [4].",
        :math => raw"""f(\mathbf{x}) = 0.25 x_1^4 - 0.5 x_1^2 + 0.1 x_1 + 0.5 x_2^2.""",  # Exakt per [RULE_SOURCE_FORMULA_CONSISTENCY]
        :start => () -> [0.0, 0.0],  # [NEW RULE_START_AWAY_FROM_MIN]
     :min_position => () -> [-1.046680529537701, 5.558876e-9],
  :min_value => () -> -0.352386073800036,
        :properties => ["bounded", "continuous", "differentiable", "separable", "unimodal"],  # Aus VALID_PROPERTIES; "non-scalable" in description [RULE_MISSING_PROPERTIES]
        :source => "Jamil & Yang (2013, p. 40)",  # Mit Seite [RULE_PROPERTIES_SOURCE]
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
@assert "zirilli_aluffipentini" == basename(@__FILE__)[1:end-3] "zirilli_aluffipentini: Dateiname mismatch!"