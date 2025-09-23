# src/functions/biggsexp6.jl
# Purpose: Implementation of the Biggs EXP6 test function.
# Context: Non-scalable (n=6), from Biggs (1971), continuous, differentiable, non-separable, multimodal, bounded.
# Global minimum: f(x*)=0 at x*=[1, 10, 1, 5, 4, 3].
# Bounds: -20 ≤ x_i ≤ 20.
# Last modified: September 23, 2025.

export BIGGSEXP6_FUNCTION, biggsexp6, biggsexp6_gradient

# Constants
const TIMES = 0.1 * collect(1:13)
const Y_VALUES = exp.(-TIMES) .- 5 * exp.(-10 * TIMES) .+ 3 * exp.(-4 * TIMES)

function biggsexp6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("Biggs EXP6 requires exactly 6 dimensions"))
    
    x1, x2, x3, x4, x5, x6 = x
    sum_sq = zero(T)
    @inbounds for i in 1:13
        t_i = TIMES[i]
        y_i = Y_VALUES[i]
        e1 = exp(-t_i * x1)
        e2 = exp(-t_i * x2)
        e5 = exp(-t_i * x5)
        term = x3 * e1 - x4 * e2 + x6 * e5 - y_i
        sum_sq += term^2
    end
    return sum_sq
end

function biggsexp6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("Biggs EXP6 requires exactly 6 dimensions"))
    
    x1, x2, x3, x4, x5, x6 = x
    grad = zeros(T, 6)
    @inbounds for i in 1:13
        t_i = TIMES[i]
        y_i = Y_VALUES[i]
        e1 = exp(-t_i * x1)
        e2 = exp(-t_i * x2)
        e5 = exp(-t_i * x5)
        term = x3 * e1 - x4 * e2 + x6 * e5 - y_i
        grad[1] += 2 * term * (-t_i * x3 * e1)
        grad[2] += 2 * term * (t_i * x4 * e2)
        grad[3] += 2 * term * e1
        grad[4] += 2 * term * (-e2)
        grad[5] += 2 * term * (-t_i * x6 * e5)
        grad[6] += 2 * term * e5
    end
    return grad
end

const BIGGSEXP6_FUNCTION = TestFunction(
    biggsexp6,
    biggsexp6_gradient,
    Dict(
        :name => "biggsexp6",
        :description => "Biggs EXP Function 6 (Biggs, 1971): A multimodal, non-separable test function for nonlinear optimization.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{13} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + x_6 e^{-t_i x_5} - y_i \right)^2, \quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}.""",
        :start => () -> [1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [1.0, 10.0, 1.0, 5.0, 4.0, 3.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :lb => () -> [-20.0, -20.0, -20.0, -20.0, -20.0, -20.0],
        :ub => () -> [20.0, 20.0, 20.0, 20.0, 20.0, 20.0],
    )
)