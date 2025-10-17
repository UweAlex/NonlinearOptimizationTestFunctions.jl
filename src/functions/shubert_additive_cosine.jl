# src/functions/shubert_additive_cosine.jl
# Purpose: Implementation of the additive cosine Shubert test function (Shubert 2).
# Global minimum: f(x*)=-25.741771 at x*≈[-1.42512843, -1.42512843] (n=2).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_ADDITIVE_COSINE_FUNCTION, shubert_additive_cosine, shubert_additive_cosine_gradient

function shubert_additive_cosine(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert_additive_cosine" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:n
        inner_sum = zero(T)
        @inbounds for j in 1:5  # j=1..5, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
            inner_sum += j * cos((j+1)*x[i] + j)
        end
        total += inner_sum
    end
    total
end

function shubert_additive_cosine_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        ∂inner = zero(T)
        @inbounds for j in 1:5
            ∂inner -= j * (j + 1) * sin((j + 1) * x[i] + j)  # Separabel: ∂/∂x_i unabhängig von anderen
        end
        grad[i] = ∂inner
    end
    grad
end

const SHUBERT_ADDITIVE_COSINE_FUNCTION = TestFunction(
    shubert_additive_cosine,
    shubert_additive_cosine_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "shubert_additive_cosine" [RULE_NAME_CONSISTENCY]
        :description => "Additive cosine Shubert function (Shubert 2); separable with ≈400 local minima in 2D; properties based on Jamil & Yang (2013, p. 56, f135); originally from Yao (1999).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j).""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(-1.42512843, n) end,  # Präzise [RULE_MIN_VALUE_INDEPENDENT]
        :min_value => (n::Int) -> n * -12.87088549772568,  # Präzise: n * min_single [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "multimodal", "separable"],
        :source => "Jamil & Yang (2013, p. 56)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(10.0, n) end,
    )
)