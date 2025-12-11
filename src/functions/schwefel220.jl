# src/functions/schwefel220.jl
# Purpose: Implementation of the Schwefel 2.20 test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-independent value).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFEL220_FUNCTION, schwefel220, schwefel220_gradient

function schwefel220(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("schwefel220 requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_abs = zero(T)
    @inbounds for i in 1:n
        sum_abs += abs(x[i])
    end
    sum_abs  # Positive sum, no minus
end

function schwefel220_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("schwefel220 requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        if x[i] > zero(T)
            grad[i] = 1
        elseif x[i] < zero(T)
            grad[i] = -1
        else
            grad[i] = zero(T)  # Subgradient at 0: 0 (choice within [-1,1])
        end
    end
    grad  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

const SCHWEFEL220_FUNCTION = TestFunction(
    schwefel220,
    schwefel220_gradient,
    Dict(
        :name => "schwefel220",  # Dynamisch: "schwefel220" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.20 test function (positive sum variant as in benchmarks); Properties based on Jamil & Yang (2013, p. 77) [adapted to standard form without erroneous n-factor or minus]; originally from Schwefel (1977). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D} |x_i|.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "partially differentiable", "separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 77)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)
