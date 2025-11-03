# src/functions/trigonometric1.jl
# Purpose: Implementation of the Trigonometric 1 test function.
# Global minimum: f(x*)=0.0 at x*=[0, ..., 0] (n-dependent position, constant value).
# Bounds: 0 ≤ x_i ≤ π.

export TRIGONOMETRIC1_FUNCTION, trigonometric1, trigonometric1_gradient

function trigonometric1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Compute sum of cos(x_j)
    sum_cos = zero(T)
    @inbounds for j in 1:n
        sum_cos += cos(x[j])
    end
    
    # Compute inner terms: [n - sum_cos + i * (1 - cos(x_i) - sin(x_i)) for i=1:n]
    # [CORRECTED: Removed 'n *' before sum_cos per source formula]
    f_val = zero(T)
    @inbounds for i in 1:n
        inner = n - sum_cos + i * (one(T) - cos(x[i]) - sin(x[i]))  # No redundant T(1.0) per [RULE_TYPE_CONVERSION_MINIMAL]
        f_val += inner^2
    end
    f_val
end

function trigonometric1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Precompute sin(x), cos(x), sum_cos
    sinx = sin.(x)
    cosx = cos.(x)
    sum_cos = zero(T)
    @inbounds for j in 1:n
        sum_cos += cosx[j]
    end
    
    # Compute inners: g_i = n - sum_cos + i * (1 - cos(x_i) - sin(x_i))
    inners = zeros(T, n)
    @inbounds for i in 1:n
        inners[i] = n - sum_cos + i * (one(T) - cosx[i] - sinx[i])
    end
    
    # sum_inners = sum g_i
    sum_inners = zero(T)
    @inbounds for i in 1:n
        sum_inners += inners[i]
    end
    
    # Gradient: ∂f/∂x_k = 2 * sin(x_k) * sum_inners + 2 * g_k * k * (sin(x_k) - cos(x_k))
    # [CORRECTED: Removed 'n *' in first term to match formula derivation]
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for k in 1:n
        term1 = 2 * sinx[k] * sum_inners
        term2 = 2 * inners[k] * k * (sinx[k] - cosx[k])
        grad[k] = term1 + term2
    end
    grad
end

const TRIGONOMETRIC1_FUNCTION = TestFunction(
    trigonometric1,
    trigonometric1_gradient,
    Dict(
        :name => "trigonometric1",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "The Trigonometric 1 function is a multimodal, non-separable trigonometric benchmark. Properties based on Jamil & Yang (2013, p. 36).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n} \left[ n - \sum_{j=1}^{n} \cos x_j + i (1 - \cos( x_i ) - \sin( x_i )) \right]^2.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 36)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension")); zeros(n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("trigonometric1 requires at least 1 dimension")); fill(pi, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "trigonometric1" == basename(@__FILE__)[1:end-3] "trigonometric1: Dateiname mismatch!"