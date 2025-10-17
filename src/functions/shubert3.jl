# src/functions/shubert3.jl
# Purpose: Implementation of the Shubert 3 test function.
# Global minimum: f(x*)=-44.51385 at x*=[-1.1141, 5.1691, 5.1691] (multiple solutions; source -29.6733337 erroneous).
# Bounds: -10 ≤ x_i ≤ 10.

export SHUBERT3_FUNCTION, shubert3, shubert3_gradient

function shubert3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert3" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("$(func_name) requires exactly 3 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_total = zero(T)
    @inbounds for i in 1:n
        sum_j = zero(T)
        @inbounds for j in 1:5
            sum_j += j * sin((j + 1) * x[i] + j)
        end
        sum_total += sum_j
    end
    sum_total  # No D multiplier
end

function shubert3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shubert3" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("$(func_name) requires exactly 3 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 3)  # [RULE_GRADTYPE]
    @inbounds for k in 1:3
        dsum = zero(T)
        @inbounds for j in 1:5
            dsum += j * (j + 1) * cos((j + 1) * x[k] + j)
        end
        grad[k] = dsum  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const SHUBERT3_FUNCTION = TestFunction(
    shubert3,
    shubert3_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "shubert3" [RULE_NAME_CONSISTENCY]
        :description => "Shubert 3 test function; Properties based on Jamil & Yang (2013, p. 134) [adapted: source min_value -29.6733337 erroneous (possibly OCR/formula error), computed -44.51385 at multiple points]; originally from Shubert (1972).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D} \sum_{j=1}^{5} j \sin((j + 1) x_i + j).""",
        :start => () -> [0.0, 0.0, 0.0],
        :min_position => () ->  [-1.1140996875874565, 5.1690856194770944, 5.1690856194770944],  # One of multiple global minima
        :min_value => () ->  -44.51385007713177,  # Computed precise value [RULE_META_CONSISTENCY]
        :properties => ["continuous", "differentiable", "separable", "multimodal", "controversial"],
        :source => "Jamil & Yang (2013, p. 134)",
        :lb => () -> [-10.0, -10.0, -10.0],
        :ub => () -> [10.0, 10.0, 10.0],
    )
)