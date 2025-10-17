# src/functions/shubert.jl
# Purpose: Implementation of the Shubert test function.
# Global minimum: f(x*)=-186.7309088310238 at x*=[-7.08350641, -1.42512843] (one of 18 global minima) [source rounds to -186.7309].
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT_FUNCTION, shubert, shubert_gradient

function shubert(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    prod_sum = one(T)
    @inbounds for i in 1:n
        sum_cos = zero(T)
        @inbounds for j in 1:5
            sum_cos += j * cos((j + 1) * x[i] + j)
        end
        prod_sum *= sum_cos
    end
    prod_sum
end

function shubert_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    
    # Compute sums for each dimension
    sum1 = zero(T)
    sum2 = zero(T)
    @inbounds for j in 1:5
        sum1 += j * cos((j + 1) * x[1] + j)
        sum2 += j * cos((j + 1) * x[2] + j)
    end
    
    # Derivatives of sums
    dsum1 = zero(T)
    dsum2 = zero(T)
    @inbounds for j in 1:5
        dsum1 -= j * (j + 1) * sin((j + 1) * x[1] + j)
        dsum2 -= j * (j + 1) * sin((j + 1) * x[2] + j)
    end
    
    # Gradient: dsum_k * prod_{i≠k} sum_i for each k
    prod_other1 = sum2
    prod_other2 = sum1
    grad[1] = dsum1 * prod_other1  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    grad[2] = dsum2 * prod_other2
    
    grad
end

const SHUBERT_FUNCTION = TestFunction(
    shubert,
    shubert_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "shubert" [RULE_NAME_CONSISTENCY]
        :description => "Shubert test function; Properties based on Jamil & Yang (2013, p. 133) [minimum controversial: source -186.7309 (rounded), precise -186.7309088310238; 18 global minima]; originally from Shubert (1972).",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^{2} \left( \sum_{j=1}^{5} j \cos((j+1) x_i + j) \right).""",
        :start => () -> [0.0, 0.0],
        :min_position => () ->   [-7.083506407203981, -1.425128428799097],  # Precise one of 18 global minima
        :min_value => () -> -186.7309088310238,  # Precise computed value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "separable", "multimodal", "controversial"],
        :source => "Jamil & Yang (2013, p. 133)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
) 