# src/functions/biggsexp3.jl
# Purpose: Implementation of the Biggs EXP Function 3 test function.
# Context: Non-scalable, fixed dimension n=3, from Biggs (1971), as described in Jamil & Yang (2013).
# Properties: continuous, differentiable, non-separable, non-scalable, multimodal, bounded.
# Global minimum: f(x*) = 0 at x* = [1.0, 10.0, 5.0].
# Bounds: 0 ≤ x_i ≤ 20.
# Last modified: September 22, 2025.

export BIGGSEXP3_FUNCTION, biggsexp3, biggsexp3_gradient

using ForwardDiff

# Precompute constants for efficiency
const BIGGS_EXP3_T = 0.1 * collect(1:10)
const BIGGS_EXP3_Y = exp.(-BIGGS_EXP3_T) .- 5 * exp.(-10 * BIGGS_EXP3_T)

function biggsexp3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Biggs EXP Function 3 requires exactly 3 dimensions"))
    
    x1, x2, x3 = x[1], x[2], x[3]
    sum_sq = zero(T)
    @inbounds for i in 1:10
        t_i = BIGGS_EXP3_T[i]
        y_i = BIGGS_EXP3_Y[i]
        e_i = exp(-t_i * x1) - x3 * exp(-t_i * x2) - y_i
        sum_sq += e_i^2
    end
    return sum_sq
end

function biggsexp3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Biggs EXP Function 3 requires exactly 3 dimensions"))
    
    x1, x2, x3 = x[1], x[2], x[3]
    grad = zeros(T, 3)
    @inbounds for i in 1:10
        t_i = BIGGS_EXP3_T[i]
        y_i = BIGGS_EXP3_Y[i]
        exp1 = exp(-t_i * x1)
        exp2 = exp(-t_i * x2)
        e_i = exp1 - x3 * exp2 - y_i
        factor = 2 * e_i
        grad[1] += factor * (-t_i * exp1)
        grad[2] += factor * (x3 * t_i * exp2)
        grad[3] += factor * (-exp2)
    end
    return grad
end

const BIGGSEXP3_FUNCTION = TestFunction(
    biggsexp3,
    biggsexp3_gradient,
    Dict(
        :name => "biggsexp3",
        :description => """
            Biggs EXP Function 3 (Biggs, 1971), as described in Jamil & Yang (2013).
            This is a multimodal function with fixed dimension n=3.
            It models an exponential fitting problem.
            """,
        :math => raw"""
            f(\mathbf{x}) = \sum_{i=1}^{10} \left( e^{-t_i x_1} - x_3 e^{-t_i x_2} - y_i \right)^2,
            \quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i}
            """,
        :start => () -> [0.01, 0.01, 0.01],
        :min_position => () -> [1.0, 10.0, 5.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal"],
        :lb => () -> [0.0, 0.0, 0.0],
        :ub => () -> [20.0, 20.0, 20.0],
    )
)