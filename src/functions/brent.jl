# src/functions/brent.jl
# Purpose: Implements the Brent test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions. Non-scalable, unimodal function with a parabolic bowl and a Gaussian bump.
# Last modified: October 22, 2025

export BRENT_FUNCTION, brent, brent_gradient

using LinearAlgebra, ForwardDiff

"""
    brent(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Brent function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function brent(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("brent requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    (x1 + 10)^2 + (x2 + 10)^2 + exp(-x1^2 - x2^2)
end

"""
    brent_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Brent function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function brent_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("brent requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    exp_term = exp(-x1^2 - x2^2)
    g1 = 2 * (x1 + 10) - 2 * x1 * exp_term
    g2 = 2 * (x2 + 10) - 2 * x2 * exp_term
    [g1, g2]
end

const BRENT_FUNCTION = TestFunction(
    brent,
    brent_gradient,
    Dict(
        :name => "brent",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-10.0, -10.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal", "bounded"],
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
        :description => "The Brent function is a non-scalable, unimodal test function with a parabolic bowl centered at (-10, -10) and a Gaussian bump at the origin. Properties based on [Jamil & Yang (2013, p. 9)]; originally from [Brent (1960)].",
        :math => raw"f(\mathbf{x}) = (x_1 + 10)^2 + (x_2 + 10)^2 + \exp(-x_1^2 - x_2^2)",
        :source => "Jamil & Yang (2013, p. 9)"
    )
)
