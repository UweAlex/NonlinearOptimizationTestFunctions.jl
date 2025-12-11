# src/functions/zettl.jl
# Purpose: Implementation of the Zettl test function.
# Global minimum: f(x*)=-0.003791 at x*=(-0.0299, 0.0).
# Bounds: -5 ≤ x_i ≤ 10.

export ZETTL_FUNCTION, zettl, zettl_gradient

function zettl(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("zettl requires exactly 2 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    # Local computation [RULE_NO_CONST_ARRAYS]
    x1 = x[1]
    x2 = x[2]
    u = x1^2 + x2^2 - T(2) * x1
    u^2 + T(0.25) * x1
end

function zettl_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("zettl requires exactly 2 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1 = x[1]
    x2 = x[2]
    u = x1^2 + x2^2 - T(2) * x1
    grad[1] = T(2) * u * (T(2) * x1 - T(2)) + T(0.25)  # ∂f/∂x1 [RULE_TYPE_CONVERSION_MINIMAL]
    grad[2] = T(2) * u * (T(2) * x2)  # ∂f/∂x2
    grad
end

const ZETTL_FUNCTION = TestFunction(
    zettl,
    zettl_gradient,
    Dict{Symbol, Any}(
        :name => "zettl",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Zettl function; Properties based on Jamil & Yang (2013, p. 40); non-scalable (fixed n=2); originally from [78].",
        :math => raw"""f(\mathbf{x}) = (x_1^2 + x_2^2 - 2x_1)^2 + 0.25 x_1.""",  # Exakt per [RULE_SOURCE_FORMULA_CONSISTENCY]
        :start => () -> [0.0, 0.0],  # [NEW RULE_START_AWAY_FROM_MIN]
  :min_position => () -> [-0.0299, 0.0],
  :min_value => () -> -0.0037912371501199,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],  # Aus VALID_PROPERTIES; "non-scalable" in description [RULE_MISSING_PROPERTIES]
        :source => "Jamil & Yang (2013, p. 40)",  # Mit Seite [RULE_PROPERTIES_SOURCE]
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
