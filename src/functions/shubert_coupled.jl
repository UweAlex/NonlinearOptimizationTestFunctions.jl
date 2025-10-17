# src/functions/shubert_coupled.jl
# Purpose: Implementation of the coupled Shubert test function (Shubert 4).
# Global minimum: f(x*)=-186.7309 at x*≈[4.858, 5.483] (n=2).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_COUPLED_FUNCTION, shubert_coupled, shubert_coupled_gradient

# Hilfsfunktion: g(x_i) = ∑ j cos((j+1)x_i + j)
function g(xi::T, ::Type{T}) where {T}
    inner_sum = zero(T)
    @inbounds for j in 1:5  # j=1..5, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
        inner_sum += j * cos((j+1)*xi + j)
    end
    inner_sum
end

function shubert_coupled(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert_coupled" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:(n-1)
        g_i = g(x[i], T)
        g_ip1 = g(x[i+1], T)
        total += g_i * g_ip1
    end
    total
end

function shubert_coupled_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for k in 1:n
        ∂g_k = zero(T)
        @inbounds for j in 1:5
            ∂g_k -= j * (j + 1) * sin((j + 1) * x[k] + j)  # ∂g/∂x_k
        end
        # Kopplung: Für k=1: ∂f/∂x_1 = ∂g_1 * g_2 (i=1)
        # Für k=n: ∂f/∂x_n = g_{n-1} * ∂g_n (i=n-1)
        # Für mittlere: + ∂g_k * g_{k-1} (i=k-1) + g_{k+1} * ∂g_k (i=k)
        if k == 1
            g_2 = g(x[2], T)
            grad[1] = ∂g_k * g_2
        elseif k == n
            g_nm1 = g(x[n-1], T)
            grad[n] = g_nm1 * ∂g_k
        else
            g_km1 = g(x[k-1], T)
            g_kp1 = g(x[k+1], T)
            grad[k] = ∂g_k * g_km1 + g_kp1 * ∂g_k
        end
    end
    grad
end

const SHUBERT_COUPLED_FUNCTION = TestFunction(
    shubert_coupled,
    shubert_coupled_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "shubert_coupled" [RULE_NAME_CONSISTENCY]
        :description => "Coupled Shubert function (Shubert 4); non-separable with 760 local minima in 2D; for n=2 identical to classical; properties based on Jamil & Yang (2013, p. 56, f135-related); originally from Yao (1999).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[\sum_{j=1}^5 j \cos((j+1)x_i + j)\right] \left[\sum_{j=1}^5 j \cos((j+1)x_{i+1} + j)\right].""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions"));  [4.8580568784680462, 5.4828642069447433] end,  # Für n=2; erweitere bei Bedarf
        :min_value => (n::Int) ->-186.73090883102375,  # Konstant für n=2; passe an [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "highly multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 56)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(10.0, n) end,
    )
)