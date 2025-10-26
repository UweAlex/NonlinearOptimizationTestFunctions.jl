# src/functions/booth.jl
# Purpose: Implements the Booth test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 22, 2025

export BOOTH_FUNCTION, booth, booth_gradient

using LinearAlgebra, ForwardDiff

"""
    booth(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Booth function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function booth(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    (x[1] + 2 * x[2] - 7)^2 + (2 * x[1] + x[2] - 5)^2
end

"""
    booth_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Booth function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function booth_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    a = x[1] + 2 * x[2] - 7
    b = 2 * x[1] + x[2] - 5
    [2 * a + 4 * b, 4 * a + 2 * b]
end

const BOOTH_FUNCTION = TestFunction(
    booth,
    booth_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 3.0],
        :min_value => () -> 0.0,
        :properties => ["unimodal", "convex", "separable", "differentiable", "bounded", "continuous"],
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
        :in_molga_smutnicki_2005 => true,
        :description => "Booth function: Unimodal, convex, separable, differentiable, bounded quadratic test function with a single global minimum at (1, 3). Properties based on [Surjanovic & Bingham (2013)]; originally from [Booth (1976)].",
        :math => raw"(x_1 + 2x_2 - 7)^2 + (2x_1 + x_2 - 5)^2",
        :source => "Surjanovic & Bingham (2013), Virtual Library of Simulation Experiments: Test Functions and Datasets, retrieved from https://www.sfu.ca/~ssurjano/booth.html"
    )
)