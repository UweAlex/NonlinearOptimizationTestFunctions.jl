# src/functions/shubert_noisy.jl
# Purpose: Noisy Shubert test function (classical Shubert with Gaussian noise).
# Global minimum: f(x*)=-186.7309 (deterministic part) at x*=(4.8580, 5.4828, ...) (18 minima in 2D).
# Bounds: -10.0 ≤ x_i ≤ 10.0.
# Note: Includes additive Gaussian noise N(0, σ²), σ=0.1.

export SHUBERT_NOISY_FUNCTION, shubert_noisy, shubert_noisy_gradient

# Lokale Hilfsfunktion für innere Summe [RULE_LOCAL_HELPERS_NAMING]
function _shubert_noisy_inner(xi::T, ::Type{T}) where {T}
    inner_sum = zero(T)
    @inbounds for j in 1:5
        inner_sum += j * cos((j + 1) * xi + j)  # [RULE_TYPE_CONVERSION_MINIMAL]
    end
    inner_sum
end

function shubert_noisy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # [RULE_NAME_CONSISTENCY]
    
    # [RULE_ERROR_HANDLING]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Shubert-Komponente
    prod = one(T)
    @inbounds for i in 1:n
        prod *= _shubert_noisy_inner(x[i], T)
    end
    
    # [RULE_NOISE_HANDLING]: Gaußsches Rauschen N(0, σ²), σ=0.1
    noise = T <: ForwardDiff.Dual ? zero(T) : T(randn() * 0.1)
    return prod + noise
end

function shubert_noisy_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    
    # [RULE_ERROR_HANDLING]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        # Produktregel: ∂f/∂x_i = (∂inner_sum_i/∂x_i) * ∏_{k≠i} inner_sum_k
        inner_sum_i = zero(T)
        deriv_inner_sum_i = zero(T)
        for j in 1:5
            inner_sum_i += j * cos((j + 1) * x[i] + j)
            deriv_inner_sum_i -= j * (j + 1) * sin((j + 1) * x[i] + j)  # [RULE_TYPE_CONVERSION_MINIMAL]
        end
        prod_others = one(T)
        for k in 1:n
            if k != i
                prod_others *= _shubert_noisy_inner(x[k], T)
            end
        end
        grad[i] = deriv_inner_sum_i * prod_others
    end
    return grad  # Rauschen hat keinen Einfluss auf Gradient
end

const SHUBERT_NOISY_FUNCTION = TestFunction(  # [RULE_TESTFUNCTION_FIELDS]
    shubert_noisy,
    shubert_noisy_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # [RULE_NAME_CONSISTENCY]
        :description => "Noisy Shubert function based on classical Shubert (f133) with additive Gaussian noise N(0, σ²), σ=0.1. Deterministic minimum is -186.7309, actual value varies due to noise. Properties based on Jamil & Yang (2013, p. 55). Originally from Shubert (1970).",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j) + \varepsilon, \quad \varepsilon \sim \mathcal{N}(0, \sigma^2).""",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Dimension must be at least 1"))
            zeros(n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Dimension must be at least 1"))
            n == 2 ? [4.8580, 5.4828] : zeros(n)  # Beispiel-Minimum für n=2
        end,
        :min_value => (n::Int) -> -186.7309,  # [RULE_MIN_VALUE_INDEPENDENT]: Deterministischer Teil
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal", "has_noise"],  # [VALID_PROPERTIES]
        :source => "Jamil & Yang (2013, p. 55)",  # [RULE_PROPERTIES_SOURCE]
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Dimension must be at least 1"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Dimension must be at least 1"))
            fill(10.0, n)
        end,
    )
)