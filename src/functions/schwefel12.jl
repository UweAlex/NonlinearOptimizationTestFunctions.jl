# src/functions/schwefel12.jl
# Purpose: Implementation of the Schwefel 1.2 test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-independent value).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFE12_FUNCTION, schwefel12, schwefel12_gradient

function schwefel12(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel12" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    prefix = zero(T)
    @inbounds for i in 1:n
        prefix += x[i]
        sum_sq += prefix^2
    end
    sum_sq
end

function schwefel12_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel12" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    if n == 0
        return grad
    end
    
    # Compute prefixes forward: p_i = sum_{j=1}^i x_j
    prefixes = Vector{T}(undef, n)
    @inbounds prefixes[1] = x[1]
    @inbounds for i = 2:n
        prefixes[i] = prefixes[i-1] + x[i]
    end
    
    # Compute suffix sums backward: s_k = sum_{i=k}^n p_i, then grad_k = 2 * s_k
    suffix_sum = zero(T)
    @inbounds for k = n:-1:1
        suffix_sum += prefixes[k]
        grad[k] = 2 * suffix_sum  # No redundant T(2) [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const SCHWEFE12_FUNCTION = TestFunction(
    schwefel12,
    schwefel12_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel12" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 1.2 test function; Properties based on Jamil & Yang (2013, p. 29); originally from Schwefel (1977). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D} \left( \sum_{j=1}^{i} x_j \right)^2.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 29)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)