# src/functions/schwefel222.jl
# Purpose: Implementation of the Schwefel 2.22 test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-independent value).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFEL222_FUNCTION, schwefel222, schwefel222_gradient

function schwefel222(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel222" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_abs = zero(T)
    prod_abs = one(T)
    @inbounds for i in 1:n
        abs_xi = abs(x[i])
        sum_abs += abs_xi
        prod_abs *= abs_xi
    end
    sum_abs + prod_abs
end

function schwefel222_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel222" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    if n == 1
        @inbounds if x[1] > zero(T)
            grad[1] = 1 + 1
        elseif x[1] < zero(T)
            grad[1] = -1 + (-1)
        end
        return grad
    end
    
    # Compute sum |x_i| gradient: sign(x_k) for each k
    # Compute prod |x_i| gradient: sign(x_k) * (prod |x_j| / |x_k|) for x_k !=0
    prod_abs = one(T)
    zero_count = 0
    @inbounds for i in 1:n
        abs_xi = abs(x[i])
        if abs_xi == zero(T)
            zero_count += 1
        end
        prod_abs *= abs_xi
    end
    
    if zero_count > 0
        prod_abs = zero(T)  # Prod=0 if any zero
    end
    
    @inbounds for k in 1:n
        if x[k] == zero(T)
            grad[k] = zero(T)  # Subgradient for sum; prod contrib 0
        else
            s_k = x[k] > zero(T) ? one(T) : -one(T)
            sum_contrib = s_k
            prod_contrib = zero(T)
            if zero_count == 0  # Only if no zeros
                prod_contrib = s_k * (prod_abs / abs(x[k]))
            end
            grad[k] = sum_contrib + prod_contrib
        end
    end
    grad  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

const SCHWEFEL222_FUNCTION = TestFunction(
    schwefel222,
    schwefel222_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel222" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.22 test function; Properties based on Jamil & Yang (2013, p. 124); originally from Schwefel (1977). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D} |x_i| + \prod_{i=1}^{D} |x_i|.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "partially differentiable", "non-separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 124)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)