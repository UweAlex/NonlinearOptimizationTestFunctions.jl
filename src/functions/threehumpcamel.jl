# src/functions/threehumpcamel.jl
# Purpose: Implements the Three-Hump Camel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 15 August 2025

export THREEHUMPCAMEL_FUNCTION, threehumpcamel, threehumpcamel_gradient

using LinearAlgebra
using ForwardDiff

"""
    threehumpcamel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Three-Hump Camel function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function threehumpcamel(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return 2 * x1^2 - 1.05 * x1^4 + (x1^6) / 6 + x1 * x2 + x2^2
end

"""
    threehumpcamel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Three-Hump Camel function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function threehumpcamel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    x1, x2 = x
    g1 = 4 * x1 - 4.2 * x1^3 + x1^5 + x2
    g2 = x1 + 2 * x2
    return [g1, g2]
end

const THREEHUMPCAMEL_FUNCTION = TestFunction(
    threehumpcamel,
    threehumpcamel_gradient,
    Dict(
        :name => "threehumpcamel",
        :start => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
            [2.0, 2.0]
        end,
        :min_position => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
            [-5.0, -5.0]
        end,
        :ub => (n::Int) -> begin
            n != 2 && throw(ArgumentError("Three-Hump Camel requires exactly 2 dimensions"))
            [5.0, 5.0]
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Three-Hump Camel function: A multimodal function with three local minima, one global.",
        :math => "f(x,y) = 2x^2 - 1.05x^4 + \\frac{x^6}{6} + xy + y^2"
    )
)