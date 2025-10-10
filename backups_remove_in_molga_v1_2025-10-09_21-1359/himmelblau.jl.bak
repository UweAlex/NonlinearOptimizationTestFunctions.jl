# src/functions/himmelblau.jl
# Purpose: Implements the Himmelblau test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 26, 2025

export HIMMELBLAU_FUNCTION, himmelblau, himmelblau_gradient

using LinearAlgebra
using ForwardDiff

"""
    himmelblau(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Himmelblau function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function himmelblau(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term1 = (x1^2 + x2 - 11)^2
    term2 = (x1 + x2^2 - 7)^2
    return term1 + term2
end

"""
    himmelblau_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Himmelblau function. Returns a vector of length 2.
"""
function himmelblau_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Himmelblau requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    grad = zeros(T, 2)
    term1 = x1^2 + x2 - 11
    term2 = x1 + x2^2 - 7
    grad[1] = 4 * x1 * term1 + 2 * term2
    grad[2] = 2 * term1 + 4 * x2 * term2
    return grad
end

const HIMMELBLAU_FUNCTION = TestFunction(
    himmelblau,
    himmelblau_gradient,
    Dict(
        :name => "himmelblau",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [3.0, 2.0],
        :min_value => () -> 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Himmelblau function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: 0.0 at [3.0, 2.0], [-2.805118, 3.131312], [-3.779310, -3.283186], [3.584428, -1.848126]. Bounds: [-5, 5]^2. Dimensions: n=2.",
        :math => "(x_1^2 + x_2 - 11)^2 + (x_1 + x_2^2 - 7)^2"
    )
)
