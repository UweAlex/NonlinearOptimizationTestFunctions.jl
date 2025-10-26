# src/functions/colville.jl
# Purpose: Implements the Colville test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 22, 2025

export COLVILLE_FUNCTION, colville, colville_gradient

using LinearAlgebra, ForwardDiff

"""
    colville(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Colville function value at point `x`. Requires exactly 4 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function colville(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("$(func_name) requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3, x4 = x
    term1 = 100 * (x1^2 - x2)^2
    term2 = (x1 - 1)^2
    term3 = (x3 - 1)^2
    term4 = 90 * (x3^2 - x4)^2
    term5 = 10.1 * ((x2 - 1)^2 + (x4 - 1)^2)
    term6 = 19.8 * (x2 - 1) * (x4 - 1)
    
    term1 + term2 + term3 + term4 + term5 + term6
end

"""
    colville_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Colville function. Returns a vector of length 4.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function colville_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("$(func_name) requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 4)
    any(isinf.(x)) && return fill(T(Inf), 4)
    
    x1, x2, x3, x4 = x
    grad = zeros(T, 4)
    grad[1] = 400 * (x1^2 - x2) * x1 + 2 * (x1 - 1)
    grad[2] = -200 * (x1^2 - x2) + 20.2 * (x2 - 1) + 19.8 * (x4 - 1)
    grad[3] = 2 * (x3 - 1) + 360 * (x3^2 - x4) * x3
    grad[4] = -180 * (x3^2 - x4) + 20.2 * (x4 - 1) + 19.8 * (x2 - 1)
    
    grad
end

const COLVILLE_FUNCTION = TestFunction(
    colville,
    colville_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :start => () -> [0.0, 0.0, 0.0, 0.0],
        :min_position => () -> [1.0, 1.0, 1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["unimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"],
        :lb => () -> fill(-10.0, 4),
        :ub => () -> fill(10.0, 4),
        :description => "Colville function: Unimodal, non-convex, non-separable, differentiable, bounded, continuous. Known for its narrow, curved valleys challenging optimization algorithms. Properties based on [Jamil & Yang (2013, p. 13)]; originally from [Colville (1968)].",
        :math => raw"f(\mathbf{x}) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)",
        :source => "Jamil & Yang (2013, p. 13)"
    )
)