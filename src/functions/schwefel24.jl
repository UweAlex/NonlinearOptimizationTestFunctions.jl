# src/functions/schwefel24.jl
# Purpose: Implementation of the Schwefel 2.4 test function.
# Global minimum: f(x*)=0.0 at x*=[1.0, 1.0].
# Bounds: 0 ≤ x_i ≤ 10.

export SCHWEFEL24_FUNCTION, schwefel24, schwefel24_gradient

function schwefel24(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel24" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Sum of (x_i - 1)^2
    sum1 = zero(T)
    @inbounds for i in 1:2
        sum1 += (x[i] - 1)^2
    end
    
    # Sum of (x_1 - x_i^2)^2
    sum2 = zero(T)
    @inbounds for i in 1:2
        sum2 += (x[1] - x[i]^2)^2
    end
    
    sum1 + sum2
end

function schwefel24_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel24" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    
    x1, x2 = x[1], x[2]
    
    # df/dx1 = 2*(x1 - 1) + 2*(x1 - x1^2)*(1 - 2*x1) + 2*(x1 - x2^2)*(1)
    # Vereinfacht: 2*(x1 - 1) + 2*(x1 - x1^2)*(1 - 2*x1) + 2*(x1 - x2^2)
    term1 = 2 * (x1 - 1)
    term2 = 2 * (x1 - x1^2) * (1 - 2 * x1)
    term3 = 2 * (x1 - x2^2)
    grad[1] = term1 + term2 + term3  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    
    # df/dx2 = 2*(x2 - 1) + 2*(x1 - x2^2)*(-2*x2)
    term4 = 2 * (x2 - 1)
    term5 = 2 * (x1 - x2^2) * (-2 * x2)
    grad[2] = term4 + term5
    
    grad
end

const SCHWEFEL24_FUNCTION = TestFunction(
    schwefel24,
    schwefel24_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel24" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.4 test function; Properties based on Jamil & Yang (2013, p. 30); originally from Schwefel (1977).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{2} (x_i - 1)^2 + (x_1 - x_i^2)^2.""",
        :start => () -> [5.0, 5.0],
        :min_position => () -> [1.0, 1.0],
        :min_value => () -> 0.0,  # Für konstante Werte: () -> value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "separable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 30)",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [10.0, 10.0],
    )
)