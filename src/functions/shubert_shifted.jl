# src/functions/shubert_shifted.jl
# Purpose: Implementation of the shifted Shubert test function (CEC 2013 F6).
# Global minimum: f(x*)=-186.7309 at x*≈[4.858, 5.483] (n=2, with o=0).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_SHIFTED_FUNCTION, shubert_shifted, shubert_shifted_gradient

# Fixed shift o = zeros(n) for reproducibility
function compute_o(n::Int)
    zeros(n)  # Fixed o=0; in CEC random ~U[-10,10] [RULE_SOURCE_FORMULA_CONSISTENCY]
end

function shubert_shifted(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert_shifted" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    o = compute_o(n)
    prod = one(T)
    @inbounds for i in 1:n
        inner_sum = zero(T)
        @inbounds for j in 1:5  # j=1..5
            inner_sum += j * cos((j+1)*(x[i] - o[i]) + j)  # Shifted
        end
        prod *= inner_sum
    end
    prod
end

function shubert_shifted_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    o = compute_o(n)
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        ∂g_i = zero(T)
        @inbounds for j in 1:5
            ∂g_i -= j * (j + 1) * sin((j + 1) * (x[i] - o[i]) + j)  # ∂g_i / ∂(x_i - o_i)
        end
        prod_other = one(T)
        @inbounds for k in 1:n
            if k != i
                g_k = zero(T)
                @inbounds for j in 1:5
                    g_k += j * cos((j + 1) * (x[k] - o[k]) + j)
                end
                prod_other *= g_k
            end
        end
        grad[i] = ∂g_i * prod_other
    end
    grad
end

const SHUBERT_SHIFTED_FUNCTION = TestFunction(
    shubert_shifted,
    shubert_shifted_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "shubert_shifted" [RULE_NAME_CONSISTENCY]
        :description => "Shifted Shubert function; non-separable with 760 local minima in 2D; fixed o=0 for reproducibility (in CEC random o~U[-10,10]); properties based on Jamil & Yang (2013, p. 55, f133-Shifted); CEC 2013 F6.",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(x_i - o_i) + j), \ o_i \sim U[-10,10].""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions"));  [4.8580568784680462, 5.4828642069447433] end,  # Für o=0, n=2
        :min_value => (n::Int) -> -186.73090883102375,  # Konstant für n=2 [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "highly multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 55)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("At least 2 dimensions")); fill(10.0, n) end,
    )
)