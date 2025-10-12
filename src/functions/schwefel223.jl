# src/functions/schwefel223.jl
# Purpose: Implementation of the Schwefel 2.23 test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-independent value).
# Bounds: -10 ≤ x_i ≤ 10.

export SCHWEFEL223_FUNCTION, schwefel223, schwefel223_gradient

function schwefel223(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel223" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_pow = zero(T)
    @inbounds for i in 1:n
        sum_pow += x[i]^10
    end
    sum_pow
end

function schwefel223_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel223" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        grad[i] = 10 * x[i]^9  # No redundant T(10) [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const SCHWEFEL223_FUNCTION = TestFunction(
    schwefel223,
    schwefel223_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel223" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.23 test function; Properties based on Jamil & Yang (2013, p. 125) [adapted to 'separable' as function is additive]; originally from Schwefel (1977). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D} x_i^{10}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 125)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(10.0, n) end,
    )
)