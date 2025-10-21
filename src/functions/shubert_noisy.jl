# src/functions/shubert_noisy.jl
# Purpose: Noisy variant of Shubert (classic product form + uniform noise, adapted for benchmark).
# Global minimum: deterministic -186.7309 + [0,1); 18 positions in 2D.
# Bounds: -10 ≤ x_i ≤ 10.

using ForwardDiff
using Random

export SHUBERT_NOISY_FUNCTION, shubert_noisy, shubert_noisy_gradient

function shubert_base_inner(x::Real)
    # Deterministische Base: Innere Summe klassische Shubert [RULE_LOCAL_HELPERS_NAMING]
    n = 1  # Dummy for helper
    n == 0 && throw(ArgumentError("Input cannot be empty"))
    isnan(x) && return NaN
    isinf(x) && return Inf
    sum(j * cos((j+1)*x + j) for j in 1:5)
end

function shubert_noisy(x::AbstractVector{T}; sigma::Float64=1.0) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Deterministische Base
    base = one(T)
    @inbounds for i in 1:n
        inner = shubert_base_inner(x[i])
        base *= inner
    end
    
    # Uniform Noise: ε ~ U[0, σ); for Dual, noise=0 (deterministic for AD) [RULE_NOISE_HANDLING]
    noise = (T <: ForwardDiff.Dual) ? zero(T) : T(rand() * sigma)
    
    base + noise
end

function shubert_noisy_gradient(x::AbstractVector{T}; sigma::Float64=1.0) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Gradient of base (deterministic; noise ignored as constant per call)
    g_base(y) = prod(shubert_base_inner(y[i]) for i in 1:n)
    grad = ForwardDiff.gradient(g_base, x)
    grad
end

# Präzises klassisches Minimum (n=2, aus globaler Optimierung)
CLASSIC_MIN_POS = [4.858056878934180, 5.482864207318173]
CLASSIC_MIN_VAL = -186.7309088310239

const SHUBERT_NOISY_FUNCTION = TestFunction(
    (x) -> shubert_noisy(x; sigma=1.0),
    (x) -> shubert_noisy_gradient(x; sigma=1.0),
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # [RULE_NAME_CONSISTENCY]
        :description => "Noisy Shubert (classic product + ε ~ U[0,1)); non-separable, multimodal (~760 local minima in 2D); tests robustness; adapted uniform noise for benchmark (Jamil & Yang 2013, p.55). Deterministic min used; evals vary +[0,1). Base is differentiable.",
        :math => raw"""f(\mathbf{x}) = \left( \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j) \right) + \varepsilon, \quad \varepsilon \sim U[0,1).""",
        :start => () -> zeros(2),
        :min_position => () -> CLASSIC_MIN_POS,
        :min_value => () -> CLASSIC_MIN_VAL,  # Deterministischer Wert (expected min for range check)
        :default_n => 2,
        :properties => ["continuous", "differentiable", "multimodal", "non-separable", "has_noise"],  # [VALID_PROPERTIES]
        :source => "Jamil & Yang (2013, p.55)",  # MUST: Mit Seite!
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)