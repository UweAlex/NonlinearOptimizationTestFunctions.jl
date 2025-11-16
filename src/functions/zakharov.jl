# src/functions/zakharov.jl
# Purpose: Implementation of the Zakharov test function.
# Global minimum: f(x*)=0.0 at x*=(0, ..., 0) (n-independent).
# Bounds: -5 ≤ x_i ≤ 10.

export ZAKHAROV_FUNCTION, zakharov, zakharov_gradient

function zakharov(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    # Compute sums locally [RULE_NO_CONST_ARRAYS]
    sum_x_sq = zero(T)
    sum_i_x = zero(T)
    @inbounds for i in 1:n  # SHOULD: @inbounds für Loops
        sum_x_sq += x[i]^2
        sum_i_x += T(i) * x[i]  # T(i) für BigFloat-Stabilität [RULE_TYPE_CONVERSION_MINIMAL]
    end
    s = T(0.5) * sum_i_x
    sum_x_sq + s^2 + s^4
end

function zakharov_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    # Compute shared s
    sum_i_x = zero(T)
    @inbounds for i in 1:n
        sum_i_x += T(i) * x[i]
    end
    s = T(0.5) * sum_i_x
    @inbounds for k in 1:n
        # ∂f/∂x_k = 2 x_k + k s + 2 k s^3  # Korrekte Ableitung
        grad[k] = T(2) * x[k] + T(k) * s + T(2) * T(k) * s^3  # T(k) für Stabilität [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const ZAKHAROV_FUNCTION = TestFunction(
    zakharov,
    zakharov_gradient,
    Dict{Symbol, Any}(
        :name => "zakharov",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Zakharov function; Properties based on Jamil & Yang (2013, p. 40); originally from Rahnamyan et al. (2007).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \left( \frac{1}{2} \sum_{i=1}^n i x_i \right)^2 + \left( \frac{1}{2} \sum_{i=1}^n i x_i \right)^4.""",  # Exakt per [RULE_SOURCE_FORMULA_CONSISTENCY]
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); fill(1.0, n) end,  # Float64-Literale [Meta-Typ-Scope-Fehler]
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "scalable"],  # "bounded" hinzugefügt (lb/ub definiert)
        :source => "Jamil & Yang (2013, p. 40)",  # Korrektur: p. 40 [RULE_PROPERTIES_SOURCE]
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); fill(-5.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "zakharov" == basename(@__FILE__)[1:end-3] "zakharov: Dateiname mismatch!"