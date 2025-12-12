# src/functions/shubert_classic.jl
# Purpose: Implementation of the classical Shubert test function (product form).
# Global minimum: f(x*)=-186.73090883102375 at x*=[4.8580568784680462, 5.4828642069447433] (one of 18 global minima).
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: December 11, 2025.

export SHUBERT_CLASSIC_FUNCTION, shubert_classic, shubert_classic_gradient

function shubert_classic(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_classic requires exactly 2 dimensions")) # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    prod = one(T)
    @inbounds for i in 1:n
        inner_sum = zero(T)
        @inbounds for j in 1:5 # j=1..5, exakt wie Quelle [RULE_SOURCE_FORMULA_CONSISTENCY]
            inner_sum += j * cos((j + 1) * x[i] + j) # Korrigiert: j * cos (bekannter Fehler in Jamil f133)
        end
        prod *= inner_sum
    end
    prod
end

function shubert_classic_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_classic requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    grad = zeros(T, n) # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        # ∂g_i / ∂x_i = - ∑ j (j+1) sin((j+1)x_i + j)
        ∂g_i = zero(T)
        @inbounds for j in 1:5
            ∂g_i -= j * (j + 1) * sin((j + 1) * x[i] + j)
        end
        # ∏_{k≠i} g_k
        prod_other = one(T)
        @inbounds for k in 1:n
            if k != i
                g_k = zero(T)
                @inbounds for j in 1:5
                    g_k += j * cos((j + 1) * x[k] + j)
                end
                prod_other *= g_k
            end
        end
        grad[i] = ∂g_i * prod_other
    end
    grad
end

const SHUBERT_CLASSIC_FUNCTION = TestFunction(
    shubert_classic,
    shubert_classic_gradient,
    Dict(
        :name => "shubert_classic", # "shubert_classic" [RULE_NAME_CONSISTENCY]
        :description => "Classical Shubert function (product of cosine sums); highly multimodal with 760 local minima in 2D; properties based on Jamil & Yang (2013, p. 55, f133); originally from Shubert (1970).",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^{2} \left( \sum_{j=1}^{5} j \cos((j+1) x_i + j) \right).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [4.8580568784680462, 5.4828642069447433],
        :min_value => () -> -186.73090883102375,
        :properties => ["continuous", "differentiable", "highly multimodal", "multimodal", "non-separable", "non-convex", "controversial"],
        :source => "Jamil & Yang (2013, p. 55)", # Direkte Quelle mit Stelle
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)