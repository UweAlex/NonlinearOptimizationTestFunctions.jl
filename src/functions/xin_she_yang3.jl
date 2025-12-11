# src/functions/xin_she_yang3.jl
# Purpose: Implementation of the Xin-She Yang No. 3 test function.
# Global minimum: f(x*)=-1.0 at x*=(0, ..., 0) (n-independent).
# Bounds: -20 ≤ x_i ≤ 20.

export XIN_SHE_YANG3_FUNCTION, xin_she_yang3, xin_she_yang3_gradient

const m = 5  # Local constant [RULE_NO_CONST_ARRAYS]
const beta = 15.0

function xin_she_yang3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    # Compute sums and product locally [RULE_NO_CONST_ARRAYS]
    sum1 = zero(T)
    sum2 = zero(T)
    prod_cos_sq = one(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum1 += (xi / T(beta))^2
        sum2 += xi^2
        prod_cos_sq *= cos(xi)^2
    end
    A = exp(-T(m) * sum1)  # [RULE_TYPE_CONVERSION_MINIMAL]: T(m) nur für Integer
    B = T(2) * exp(-sum2) * prod_cos_sq  # Korrektur: Kein *n (D); exakt per Quelle
    A - B
end

function xin_she_yang3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    # Compute shared terms
    sum1 = zero(T)
    sum2 = zero(T)
    prod_cos_sq = one(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum1 += (xi / T(beta))^2
        sum2 += xi^2
        prod_cos_sq *= cos(xi)^2
    end
    A = exp(-T(m) * sum1)
    exp_sum2 = exp(-sum2)
    # B = 2 * exp_sum2 * prod_cos_sq  # Für Ableitung
    @inbounds for k in 1:n
        xk = x[k]
        # ∂A/∂x_k = -2 m x_k / β^2 * A
        dA_dxk = -T(2) * T(m) / (T(beta)^2) * xk * A
        # ∂B/∂x_k = -4 * exp(-sum2) * prod_cos_sq * (x_k + tan(x_k))
        dB_dxk = -T(4) * exp_sum2 * prod_cos_sq * (xk + tan(xk))  # Korrektur: Kein *n; exakt per Ableitung
        grad[k] = dA_dxk - dB_dxk  # ∇f = ∇A - ∇B
    end
    grad
end

const XIN_SHE_YANG3_FUNCTION = TestFunction(
    xin_she_yang3,
    xin_she_yang3_gradient,
    Dict{Symbol, Any}(
        :name => "xin_she_yang3",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Xin-She Yang No. 3 function; Properties based on Jamil & Yang (2013, p. 39); originally proposed by Xin-She Yang.",
        :math => raw"""f(\mathbf{x}) = \left[ e^{-\sum_{i=1}^{D} \left( \frac{x_i}{\beta} \right)^2 m} - 2 e^{-\sum_{i=1}^{D} x_i^2} \cdot \prod_{i=1}^{D} \cos^2 (x_i) \right]""",  # Exakt per [RULE_SOURCE_FORMULA_CONSISTENCY]
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension")); fill(1.0, n) end,  # Float64-Literale [Meta-Typ-Scope-Fehler]
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> -1.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "multimodal", "non-separable", "scalable"],  # Aus VALID_PROPERTIES
        :source => "Jamil & Yang (2013, p. 39)",  # Mit Seite [RULE_PROPERTIES_SOURCE]
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension")); fill(-20.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang3 requires at least 1 dimension")); fill(20.0, n) end,
    )
)

# Optional: Validierung beim Laden
