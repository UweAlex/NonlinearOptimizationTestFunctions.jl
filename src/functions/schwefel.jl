# src/functions/schwefel.jl
# Purpose: Implementation of the Schwefel Function [7] test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n) (n-dependent).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFEL_FUNCTION, schwefel, schwefel_gradient

function schwefel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch, angepasst für scalable [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    sum_sq^2  # α=2.0; keine T(2.0) [RULE_TYPE_CONVERSION_MINIMAL]
end

function schwefel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel"
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for j in 1:n
        grad[j] = 4 * sum_sq * x[j]  # Für α=2: 2 * sum_sq * 2 * x[j]; keine T(4) [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const SCHWEFEL_FUNCTION = TestFunction(
    schwefel,
    schwefel_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel" – exakt Dateiname [RULE_NAME_CONSISTENCY]
        :description => "The Schwefel Function [7] with α=2.0 (chosen for concrete unimodal variant; general α≥0 per source). Properties based on Jamil & Yang (2013, p. 118); originally from Schwefel (various works).",
        :math => raw"""f(\mathbf{x}) = \left( \sum_{i=1}^{D} x_i^2 \right)^2.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; hier 2 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "partially separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 118)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)