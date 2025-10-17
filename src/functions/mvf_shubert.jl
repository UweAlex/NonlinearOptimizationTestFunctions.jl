# src/functions/mvf_shubert.jl
# Purpose: Implementation of the mvfShubert test function (Adorio variant, 2D fixed).
# Global minimum: f(x*)=-24.0625 at x*≈[-0.49139, 5.79179].
# Bounds: -10 ≤ x_i ≤ 10.

export MVF_SHUBERT_FUNCTION, mvf_shubert, mvf_shubert_gradient

function mvf_shubert(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "mvf_shubert" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Fixed 2D [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 0:1  # i=0..1 für 2D
        @inbounds for j in 0:4  # j=0..4, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
            total -= (j+1) * sin((j+2)*x[i+1] + (j+1))  # x[1] für i=0, x[2] für i=1
        end
    end
    total
end

function mvf_shubert_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # Fixed 2D [RULE_GRADTYPE]
    @inbounds for i in 0:1
        ∂inner = zero(T)
        @inbounds for j in 0:4
            ∂inner -= (j+1) * (j+2) * cos((j+2)*x[i+1] + (j+1))  # Separabel: ∂/∂x_i
        end
        grad[i+1] = ∂inner
    end
    grad
end

const MVF_SHUBERT_FUNCTION = TestFunction(
    mvf_shubert,
    mvf_shubert_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "mvf_shubert" [RULE_NAME_CONSISTENCY]
        :description => "mvfShubert (Adorio variant, 2D fixed, additive sine with index shift j=0..4); separable with ≈400 local minima; properties based on Adorio (2005, p. 12–13); similar to Shubert 3 but with offsets.",
        :math => raw"""f(\mathbf{x}) = -\sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).""",
        :start => () -> zeros(2),  # Fixed 2D
        :min_position => () -> [-0.4913908362396234, 5.7917944715808174],  # Präzise [RULE_MIN_VALUE_INDEPENDENT]
        :min_value => () -> -24.062498884334282,  # Konstant [RULE_META_CONSISTENCY]
        :default_n => 2,  # Für Konsistenz, obwohl fixed
        :properties => ["continuous", "differentiable", "multimodal", "separable"],
        :source => "Adorio (2005, p. 12)",  # Direkte Quelle mit Stelle
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)