# src/functions/mvf_shubert2.jl
# Purpose: Implementation of the mvfShubert2 test function (Adorio variant, 2D fixed).
# Global minimum: f(x*)=-25.741771 at x*≈[-1.42512843, -1.42512843].
# Bounds: -10 ≤ x_i ≤ 10.

export MVF_SHUBERT2_FUNCTION, mvf_shubert2, mvf_shubert2_gradient

function mvf_shubert2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("mvf_shubert2 requires exactly 2 dimensions"))  # Fixed 2D [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 0:1  # i=0..1 für 2D
        @inbounds for j in 0:4  # j=0..4, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
            total += (j+1) * cos((j+2)*x[i+1] + (j+1))  # x[1] für i=0, x[2] für i=1
        end
    end
    total
end

function mvf_shubert2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("mvf_shubert2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # Fixed 2D [RULE_GRADTYPE]
    @inbounds for i in 0:1
        ∂inner = zero(T)
        @inbounds for j in 0:4
            ∂inner -= (j+1) * (j+2) * sin((j+2)*x[i+1] + (j+1))  # Separabel: ∂/∂x_i
        end
        grad[i+1] = ∂inner
    end
    grad
end

const MVF_SHUBERT2_FUNCTION = TestFunction(
    mvf_shubert2,
    mvf_shubert2_gradient,
    Dict(
        :name => "mvf_shubert2",  # "mvf_shubert2" [RULE_NAME_CONSISTENCY]
        :description => "mvfShubert2 (Adorio variant, 2D fixed, additive cosine with index shift j=0..4); separable with ≈400 local minima; properties based on Adorio (2005, p. 13); similar to Shubert 2 but with offsets.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\cos((j+2)x_i+(j+1)).""",
        :start => () -> zeros(2),  # Fixed 2D
        :min_position => () -> [-1.42512843, -1.42512843],  # Präzise [RULE_MIN_VALUE_INDEPENDENT]
        :min_value => () -> -25.74177099545137,  # Präzise [RULE_META_CONSISTENCY]
        :default_n => 2,  # Für Konsistenz, obwohl fixed
        :properties => ["continuous", "differentiable", "multimodal", "separable"],
        :source => "Adorio (2005, p. 13)",  # Direkte Quelle mit Stelle
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

