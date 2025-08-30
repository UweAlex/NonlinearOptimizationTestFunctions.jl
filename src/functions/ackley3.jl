# src/functions/ackley3.jl
# Purpose: Implements the Ackley3 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 30, 2025

export ACKLEY3_FUNCTION, ackley3, ackley3_gradient

using LinearAlgebra
using ForwardDiff

"""
    ackley3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Ackley3 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function ackley3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    r = sqrt(x[1]^2 + x[2]^2)
    return T(-200.0) * exp(T(-0.02) * r) + T(5.0) * exp(cos(T(3.0) * x[1]) + sin(T(3.0) * x[2]))
end

"""
    ackley3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Ackley3 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function ackley3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    r = sqrt(x[1]^2 + x[2]^2)
    grad = zeros(T, 2)
    if r != 0.0
        exp_term = exp(T(-0.02) * r)
        factor = T(4.0) * exp_term / r
        grad[1] += factor * x[1]
        grad[2] += factor * x[2]
    end
    exp_term2 = exp(cos(T(3.0) * x[1]) + sin(T(3.0) * x[2]))
    grad[1] += T(-15.0) * sin(T(3.0) * x[1]) * exp_term2
    grad[2] += T(15.0) * cos(T(3.0) * x[2]) * exp_term2
    return grad
end

const ACKLEY3_META = Dict(
    :name => "ackley3",
    :start => () -> [0.0, 0.0],
    :min_position => () -> [0.682584587365898, -0.36075325513719],
    :min_value => -195.629028238419,
    :properties => Set(["unimodal", "non-separable", "differentiable", "continuous", "bounded"]),
    :lb => () -> [-32.0, -32.0],
    :ub => () -> [32.0, 32.0],
    :in_molga_smutnicki_2005 => false,
    :description => "Ackley3 function: Continuous, differentiable, non-separable, non-scalable, unimodal.",
    :math => "\\f(x) = -200 e^{-0.02 \\sqrt{x_1^2 + x_2^2}} + 5 e^{\\cos(3x_1) + \\sin(3x_2)}"
)

const ACKLEY3_FUNCTION = TestFunction(
    ackley3,
    ackley3_gradient,
    ACKLEY3_META
)