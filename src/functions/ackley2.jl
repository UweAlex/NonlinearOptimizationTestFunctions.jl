# src/functions/ackley2.jl
# Purpose: Implements the Ackley2 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 24, 2025

export ACKLEY2_FUNCTION, ackley2, ackley2_gradient

using LinearAlgebra
using ForwardDiff

"""
    ackley2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Ackley2 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function ackley2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    r = sqrt(x[1]^2 + x[2]^2)
    return T(-200.0) * exp(T(-0.02) * r)
end

"""
    ackley2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Ackley2 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function ackley2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    r = sqrt(x[1]^2 + x[2]^2)
    if r == 0.0
        return fill(T(0.0), 2)
    else
        exp_term = exp(T(-0.02) * r)
        factor = T(4.0) * exp_term / r
        return factor * x
    end
end

const ACKLEY2_META = Dict(
    :name => "ackley2",
    :start => () -> [0.0, 0.0],
    :min_position => () -> [0.0, 0.0],
    :min_value => -200.0,
    :properties => Set(["unimodal", "non-convex", "non-separable", "partially differentiable", "continuous", "bounded"]),
    :lb => () -> [-32.0, -32.0],
    :ub => () -> [32.0, 32.0],
    :in_molga_smutnicki_2005 => false,
    :description => "Ackley2 function: Continuous, partially differentiable, non-separable, non-scalable, unimodal.",
    :math => "\\f(x) = -200 e^{-0.02 \\sqrt{x_1^2 + x_2^2}}"
)

const ACKLEY2_FUNCTION = TestFunction(
    ackley2,
    ackley2_gradient,
    ACKLEY2_META
)