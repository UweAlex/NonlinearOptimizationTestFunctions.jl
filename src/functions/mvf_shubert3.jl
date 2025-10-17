# src/functions/mvf_shubert3.jl
# Purpose: Implementation of the mvfShubert3 test function (Adorio nD generalization).
# Global minimum: f(x*)=-24.0625 at x*≈[-0.49139, -0.49139] (n=2; multiple global minima due to periodicity).
# Bounds: -10 ≤ x_i ≤ 10.

export MVF_SHUBERT3_FUNCTION, mvf_shubert3, mvf_shubert3_gradient

function mvf_shubert3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "mvf_shubert3" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:n  # i=1..n (angepasst von 0..n-1)
        @inbounds for j in 0:4  # j=0..4, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
            total -= (j+1) * sin((j+2)*x[i] + (j+1))
        end
    end
    total
end

function mvf_shubert3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        ∂inner = zero(T)
        @inbounds for j in 0:4
            ∂inner -= (j+1) * (j+2) * cos((j+2)*x[i] + (j+1))  # Separabel: ∂/∂x_i
        end
        grad[i] = ∂inner
    end
    grad
end

const MVF_SHUBERT3_FUNCTION = TestFunction(
    mvf_shubert3,
    mvf_shubert3_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "mvf_shubert3" [RULE_NAME_CONSISTENCY]
        :description => "mvfShubert3 (Adorio nD generalization, additive sine with index shift j=0..4); separable with ≈400 local minima in 2D; properties based on Adorio (2005, p. 13); generalization of mvfShubert.",
        :math => raw"""f(\mathbf{x}) = -\sum_{i=0}^{n-1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-0.4913908340773322, n) end,  # Konsistente Pos pro Dim (multiple Globalminima) [RULE_MIN_VALUE_INDEPENDENT]
        :min_value => (n::Int) -> n * -12.031249442167137,  # n * min_single [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "multimodal", "separable"],
        :source => "Adorio (2005, p. 13)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(10.0, n) end,
    )
)