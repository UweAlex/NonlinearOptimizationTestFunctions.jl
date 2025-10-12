# src/functions/schwefel236.jl
# Purpose: Implementation of the Schwefel 2.36 test function.
# Global minimum: f(x*)=-3456.0 at x*=[12.0, 12.0].
# Bounds: 0 ≤ x_i ≤ 500.

export SCHWEFEL236_FUNCTION, schwefel236, schwefel236_gradient

function schwefel236(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel236" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    -x1 * x2 * (72 - 2 * x1 - 2 * x2)
end

function schwefel236_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel236" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    
    x1, x2 = x[1], x[2]
    
    # ∂f/∂x1 = -72 x2 + 4 x1 x2 + 2 x2^2
    grad[1] = -72 * x2 + 4 * x1 * x2 + 2 * x2^2
    
    # ∂f/∂x2 = -72 x1 + 2 x1^2 + 4 x1 x2
    grad[2] = -72 * x1 + 2 * x1^2 + 4 * x1 * x2  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    
    grad
end

const SCHWEFEL236_FUNCTION = TestFunction(
    schwefel236,
    schwefel236_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel236" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.36 test function; Properties based on Jamil & Yang (2013, p. 129) [adapted: non-separable due to coupling, unimodal as quadratic]; originally from Schwefel (1981).",
        :math => raw"""f(\mathbf{x}) = -x_1 x_2 (72 - 2 x_1 - 2 x_2).""",
        :start => () -> [250.0, 250.0],
        :min_position => () -> [12.0, 12.0],
        :min_value => () -> -3456.0,  # Für konstante Werte: () -> value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 129)",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [500.0, 500.0],
    )
)