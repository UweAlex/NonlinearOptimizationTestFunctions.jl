# src/functions/shubert_hybrid_rastrigin.jl
# Purpose: Implementation of the hybrid Shubert-Rastrigin test function (composition).
# Global minimum: f(x*)=-79.36953019911927 at x*=[-0.81305, -1.41788] (n=2, weights 0.5/0.5).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_HYBRID_RASTRIGIN_FUNCTION, shubert_hybrid_rastrigin, shubert_hybrid_rastrigin_gradient

# Lokale Gewichte [RULE_NO_CONST_ARRAYS]
function _hybrid_compute_weights(::Type{T}) where {T}
    w1 = T(0.5)  # Shubert-Gewicht
    w2 = T(0.5)  # Rastrigin-Gewicht
    (w1, w2)
end

# Hilfsfunktion: Shubert inner sum [RULE_LOCAL_HELPERS_NAMING]
function _hybrid_shubert_inner(xi::T, ::Type{T}) where {T}
    inner_sum = zero(T)
    @inbounds for j in 1:5
        inner_sum += j * cos((j+1)*xi + j)
    end
    inner_sum
end

# Rastrigin-Komponente
function _hybrid_rastrigin_component(x::AbstractVector{T}) where {T}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))  # [RULE_LOCAL_HELPERS_ERROR_HANDLING]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    A = T(10)
    pi_T = T(pi)  # Explizite Typkonvertierung
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2 - A * cos(2 * pi_T * x[i])
    end
    n * A + sum_sq
end

function shubert_hybrid_rastrigin(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_hybrid_rastrigin requires exactly 2 dimensions"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    w1, w2 = _hybrid_compute_weights(T)
    
    shubert_val = one(T)
    @inbounds for i in 1:n
        shubert_val *= _hybrid_shubert_inner(x[i], T)
    end
    
    rastrigin_val = _hybrid_rastrigin_component(x)
    
    w1 * shubert_val + w2 * rastrigin_val
end

function shubert_hybrid_rastrigin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_hybrid_rastrigin requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    w1, w2 = _hybrid_compute_weights(T)
    
    grad_shubert = zeros(T, n)
    @inbounds for i in 1:n
        ∂g_i = zero(T)
        @inbounds for j in 1:5
            ∂g_i -= j * (j + 1) * sin((j + 1) * x[i] + j)
        end
        prod_other = one(T)
        @inbounds for k in 1:n
            if k != i
                prod_other *= _hybrid_shubert_inner(x[k], T)
            end
        end
        grad_shubert[i] = ∂g_i * prod_other
    end
    
    grad_rastrigin = zeros(T, n)
    A = T(10)
    pi_T = T(pi)
    @inbounds for i in 1:n
        grad_rastrigin[i] = 2 * x[i] + A * 2 * pi_T * sin(2 * pi_T * x[i])
    end
    
    w1 * grad_shubert + w2 * grad_rastrigin
end

const SHUBERT_HYBRID_RASTRIGIN_FUNCTION = TestFunction(
    shubert_hybrid_rastrigin,
    shubert_hybrid_rastrigin_gradient,
    Dict(
        :name => "shubert_hybrid_rastrigin",  # [RULE_NAME_CONSISTENCY]
        :description => "Hybrid Shubert-Rastrigin composition (weights 0.5/0.5, n=2); non-separable multimodal hybrid; properties based on Jamil & Yang (2013, p. 56, Hybrid-Variante); CEC 2020 F10.",
        :math => raw"""f(\mathbf{x}) = 0.5 \cdot \text{Shubert}(\mathbf{x}) + 0.5 \cdot \text{Rastrigin}(\mathbf{x}).""",
        :start => () -> [0.0, 0.0],
        :min_position => () ->  [-0.8130518668176654, -1.4178774389880957],
        :min_value => () -> -79.36953021020285,  # Korrigierter Wert
        :default_n => 2,  # [SHOULD]: Für Konsistenz
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "ill-conditioned"],  # Korrigiert
        :source => "Jamil & Yang (2013, p. 56)",  # [RULE_PROPERTIES_SOURCE]
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

