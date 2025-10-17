# src/functions/shubert_generalized.jl
# Purpose: Implementation of the generalized Shubert test function (parametric additive).
# Global minimum: f(x*)=-25.741771 at x*≈[-1.42512843, -1.42512843] (n=2, standard params).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_GENERALIZED_FUNCTION, shubert_generalized, shubert_generalized_gradient

function shubert_generalized(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert_generalized" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Lokale Params (kein global const-Array [RULE_NO_CONST_ARRAYS])
    a = [1.0, 2.0, 3.0, 4.0, 5.0]  # Dynamisch, inline
    b = [2.0, 3.0, 4.0, 5.0, 6.0]
    c = [1.0, 2.0, 3.0, 4.0, 5.0]
    
    total = zero(T)
    @inbounds for i in 1:n
        inner_sum = zero(T)
        @inbounds for jj in 1:5  # j=1..5
            inner_sum += a[jj] * cos(b[jj]*x[i] + c[jj])  # Standard-Params [RULE_SOURCE_FORMULA_CONSISTENCY]
        end
        total += inner_sum
    end
    total
end

function shubert_generalized_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Lokale Params (kein global const [RULE_NO_CONST_ARRAYS])
    a = [1.0, 2.0, 3.0, 4.0, 5.0]
    b = [2.0, 3.0, 4.0, 5.0, 6.0]
    c = [1.0, 2.0, 3.0, 4.0, 5.0]
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        ∂inner = zero(T)
        @inbounds for jj in 1:5
            ∂inner -= a[jj] * b[jj] * sin(b[jj]*x[i] + c[jj])  # Separabel: ∂/∂x_i
        end
        grad[i] = ∂inner
    end
    grad
end

const SHUBERT_GENERALIZED_FUNCTION = TestFunction(
    shubert_generalized,
    shubert_generalized_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # "shubert_generalized" [RULE_NAME_CONSISTENCY]
        :description => "Generalized Shubert function (parametric additive cosine); separable with ≈400 local minima in 2D; standard params (a_j=j, b_j=j+1, c_j=j) identical to Shubert 2; properties based on Jamil & Yang (2013, p. 56, f135-Generalized); CEC 2008–2013.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 a_j \cos(b_j x_i + c_j).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-1.42512843, n) end,  # Präzise [RULE_MIN_VALUE_INDEPENDENT]
        :min_value => (n::Int) -> n * -12.870885497725686,  # Präzise: n * min_single [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "multimodal", "separable"],
        :source => "Jamil & Yang (2013, p. 56)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("At least 1 dimension")); fill(10.0, n) end,
    )
)