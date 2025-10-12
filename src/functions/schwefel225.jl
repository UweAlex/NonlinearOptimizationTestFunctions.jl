# src/functions/schwefel225.jl
# Purpose: Implementation of the Schwefel 2.25 test function.
# Global minimum: f(x*)=0.0 at x*=[1.0, 1.0].
# Bounds: 0 ≤ x_i ≤ 10.

export SCHWEFEL225_FUNCTION, schwefel225, schwefel225_gradient

function schwefel225(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel225" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    term1 = (x2 - 1)^2
    term2 = (x1 - x2^2)^2
    term1 + term2
end

function schwefel225_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel225" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    
    x1, x2 = x[1], x[2]
    
    # df/dx1 = 2 * (x1 - x2^2) * 1
    grad[1] = 2 * (x1 - x2^2)
    
    # df/dx2 = 2 * (x2 - 1) + 2 * (x1 - x2^2) * (-2 * x2)
    grad[2] = 2 * (x2 - 1) + 2 * (x1 - x2^2) * (-2 * x2)  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    
    grad
end

const SCHWEFEL225_FUNCTION = TestFunction(
    schwefel225,
    schwefel225_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel225" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.25 test function; Properties based on Jamil & Yang (2013, p. 127) [separable per source, though coupled terms]; originally from Schwefel (1977).",
        :math => raw"""f(\mathbf{x}) = (x_2 - 1)^2 + (x_1 - x_2^2)^2.""",
        :start => () -> [5.0, 5.0],
        :min_position => () -> [1.0, 1.0],
        :min_value => () -> 0.0,  # Für konstante Werte: () -> value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "separable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 127)",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [10.0, 10.0],
    )
)