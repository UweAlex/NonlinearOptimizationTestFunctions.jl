# src/functions/biggsexp5.jl
# Purpose: Implementation of the Biggs EXP Function 5 test function.
# Context: Non-scalable, fixed dimension n=5, from Biggs (1971), as described in Jamil & Yang (2013).
# Properties: continuous, differentiable, non-separable, multimodal, bounded.
# Global minimum: f(x*) = 0 at x* = [1.0, 10.0, 1.0, 5.0, 4.0].
# Bounds: 0 ≤ x_i ≤ 20.
# Last modified: September 22, 2025.

export BIGGSEXP5_FUNCTION, biggsexp5, biggsexp5_gradient

# Precompute constants for efficiency
const BIGGS_EXP5_T = 0.1 * collect(1:11)
const BIGGS_EXP5_Y = exp.(-BIGGS_EXP5_T) .- 5 * exp.(-10 * BIGGS_EXP5_T) .+ 3 * exp.(-4 * BIGGS_EXP5_T)

function biggsexp5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("Biggs EXP Function 5 requires exactly 5 dimensions"))
    
    x1, x2, x3, x4, x5 = x[1], x[2], x[3], x[4], x[5]
    sum_sq = zero(T)
    @inbounds for i in 1:11
        t_i = BIGGS_EXP5_T[i]
        y_i = BIGGS_EXP5_Y[i]
        e_i = x3 * exp(-t_i * x1) - x4 * exp(-t_i * x2) + 3 * exp(-t_i * x5) - y_i
        sum_sq += e_i^2
    end
    return sum_sq
end

function biggsexp5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("Biggs EXP Function 5 requires exactly 5 dimensions"))
    
    x1, x2, x3, x4, x5 = x[1], x[2], x[3], x[4], x[5]
    grad = zeros(T, 5)
    @inbounds for i in 1:11
        t_i = BIGGS_EXP5_T[i]
        y_i = BIGGS_EXP5_Y[i]
        exp1 = exp(-t_i * x1)
        exp2 = exp(-t_i * x2)
        exp5 = exp(-t_i * x5)
        e_i = x3 * exp1 - x4 * exp2 + 3 * exp5 - y_i
        factor = 2 * e_i
        grad[1] += factor * (x3 * (-t_i) * exp1)
        grad[2] += factor * (x4 * t_i * exp2)
        grad[3] += factor * exp1
        grad[4] += factor * (-exp2)
        grad[5] += factor * (3 * (-t_i) * exp5)
    end
    return grad
end

const BIGGSEXP5_FUNCTION = TestFunction(
    biggsexp5,
    biggsexp5_gradient,
    Dict(
        :name => "biggsexp5",
        :description => """
            Biggs EXP Function 5 (Biggs, 1971), as described in Jamil & Yang (2013).
            This is a multimodal function with fixed dimension n=5.
            It models an exponential fitting problem.
            """,
        :math => raw"""
            f(\mathbf{x}) = \sum_{i=1}^{11} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + 3 e^{-t_i x_5} - y_i \right)^2,
            \quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}
            """,
        :start => () -> [0.01, 0.01, 0.01, 0.01, 0.01],
        :min_position => () -> [1.0, 10.0, 1.0, 5.0, 4.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :lb => () -> [0.0, 0.0, 0.0, 0.0, 0.0],
        :ub => () -> [20.0, 20.0, 20.0, 20.0, 20.0]
    )
)