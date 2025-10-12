# src/functions/schwefel26.jl
# Purpose: Implementation of the Schwefel 2.6 test function.
# Global minimum: f(x*)=0.0 at x*=[1.0, 3.0].
# Bounds: -100 ≤ x_i ≤ 100.

export SCHWEFEL26_FUNCTION, schwefel26, schwefel26_gradient

function schwefel26(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel26" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    a = x1 + 2 * x2 - 7
    b = 2 * x1 + x2 - 5
    u = abs(a)
    v = abs(b)
    max(u, v)
end

function schwefel26_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel26" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    
    x1, x2 = x[1], x[2]
    a = x1 + 2 * x2 - 7
    b = 2 * x1 + x2 - 5
    u = abs(a)
    v = abs(b)
    
    if u > v
        # Gradient of |a|: sign(a) * [1, 2]
        s_a = a == zero(T) ? zero(T) : a / abs(a)  # sign(a), 0 at 0
        grad[1] = s_a * 1
        grad[2] = s_a * 2
    elseif v > u
        # Gradient of |b|: sign(b) * [2, 1]
        s_b = b == zero(T) ? zero(T) : b / abs(b)  # sign(b), 0 at 0
        grad[1] = s_b * 2
        grad[2] = s_b * 1
    else
        # At u == v, subgradient: choose 0 for simplicity (e.g. at minimum)
        grad .= zero(T)
    end
    
    grad  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
end

const SCHWEFEL26_FUNCTION = TestFunction(
    schwefel26,
    schwefel26_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel26" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.6 test function (piecewise linear); Properties based on Jamil & Yang (2013, p. 31); originally from Schwefel (1981). Global minimum where both arguments are zero.",
        :math => raw"""f(\mathbf{x}) = \max(|x_1 + 2x_2 - 7|, |2x_1 + x_2 - 5|).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 3.0],
        :min_value => () -> 0.0,  # Für konstante Werte: () -> value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 31)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)