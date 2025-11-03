# src/functions/trigonometric2.jl
# Purpose: Implementation of the Trigonometric 2 test function.
# Global minimum: f(x*)=1.0 at x*=[0.9, ..., 0.9] (n-dependent position, constant value).
# Bounds: -500 ≤ x_i ≤ 500.

export TRIGONOMETRIC2_FUNCTION, trigonometric2, trigonometric2_gradient

function trigonometric2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    c = T(0.9)  # Local constant [RULE_NO_CONST_ARRAYS]
    sum_term = zero(T)
    @inbounds for i in 1:n
        v = x[i] - c
        u = 7 * v^2
        sum_term += 8 * sin(u)^2 + v^2  # No redundant T() per [RULE_TYPE_CONVERSION_MINIMAL]
    end
    
    extra_term = zero(T)
    if n >= 1
        v1 = x[1] - c
        w = 14 * v1^2
        extra_term = 6 * sin(w)^2
    end
    
    one(T) + sum_term + extra_term
end

function trigonometric2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    c = T(0.9)  # Local constant
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    
    @inbounds for k in 1:n
        v_k = x[k] - c
        u_k = 7 * v_k^2
        sin_2u_k = sin(2 * u_k)  # 2 sin(u) cos(u) = sin(2u)
        common_deriv = 112 * v_k * sin_2u_k + 2 * v_k  # 8 * sin(2u) * 14 v + 2 v
        grad[k] = common_deriv
    end
    
    # Extra for k=1
    if n >= 1
        v1 = x[1] - c
        w1 = 14 * v1^2
        sin_2w1 = sin(2 * w1)
        extra_deriv1 = 168 * v1 * sin_2w1  # 6 * sin(2w) * 28 v
        grad[1] += extra_deriv1
    end
    
    grad
end

const TRIGONOMETRIC2_FUNCTION = TestFunction(
    trigonometric2,
    trigonometric2_gradient,
    Dict(
        :name => "trigonometric2",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "The Trigonometric 2 function is a multimodal, non-separable benchmark with asymmetric oscillatory terms centered around 0.9. Properties based on Jamil & Yang (2013, p. 36).",
        :math => raw"""f(\mathbf{x}) = 1 + \sum_{i=1}^n \left[ 8 \sin^2 \left( 7 (x_i - 0.9)^2 \right) + (x_i - 0.9)^2 \right] + 6 \sin^2 \left( 14 (x_1 - 0.9)^2 \right).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension")); fill(0.9, n) end,
        :min_value => (n::Int) -> 1.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 36)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension")); fill(-500.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric2 requires at least 1 dimension")); fill(500.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "trigonometric2" == basename(@__FILE__)[1:end-3] "trigonometric2: Dateiname mismatch!"