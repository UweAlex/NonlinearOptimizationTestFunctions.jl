# src/functions/schwefel221.jl
# Purpose: Implementation of the Schwefel 2.21 test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-independent value).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFEL221_FUNCTION, schwefel221, schwefel221_gradient

function schwefel221(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel221" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    max_abs = zero(T)
    @inbounds for i in 1:n
        max_abs = max(max_abs, abs(x[i]))
    end
    max_abs
end

function schwefel221_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel221" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    if all(abs.(x) .== zero(T))
        return grad  # At all zeros: subgradient 0
    end
    
    # Find index j with max |x_j| (first if ties)
    max_idx = 1
    max_val = abs(x[1])
    @inbounds for i in 2:n
        abs_xi = abs(x[i])
        if abs_xi > max_val
            max_val = abs_xi
            max_idx = i
        end
    end
    
    # Subgradient: sign(x_j) at j, 0 elsewhere
    if x[max_idx] > zero(T)
        grad[max_idx] = 1
    elseif x[max_idx] < zero(T)
        grad[max_idx] = -1
    end  # At 0: already 0
    
    grad  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

const SCHWEFEL221_FUNCTION = TestFunction(
    schwefel221,
    schwefel221_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel221" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.21 test function; Properties based on Jamil & Yang (2013, p. 123); originally from Schwefel (1977). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \max_{1 \leq i \leq D} |x_i|.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "partially differentiable", "separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 123)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)