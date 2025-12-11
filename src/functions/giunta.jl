# src/functions/giunta.jl
# Purpose: Implements the Giunta test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 26, 2025

export GIUNTA_FUNCTION, giunta, giunta_gradient

using LinearAlgebra
using ForwardDiff

"""
    giunta(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Giunta function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function giunta(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Giunta requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = T(0.6)
    for i in 1:2
        z = (16/15) * x[i] - 1
        sum += sin(z) + sin(z)^2 + (1/50) * sin(4 * z)
    end
    return sum
end

"""
    giunta_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Giunta function. Returns a vector of length 2.
"""
function giunta_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Giunta requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    grad = zeros(T, 2)
    for i in 1:2
        z = (16/15) * x[i] - 1
        grad[i] = (16/15) * (cos(z) + 2 * sin(z) * cos(z) + (4/50) * cos(4 * z))
    end
    return grad
end

const GIUNTA_FUNCTION = TestFunction(
    giunta,
    giunta_gradient,
    Dict(
        :name => "giunta",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.46732002530945826, 0.46732002530945826],
        :min_value => () -> 0.06447042053690566,
        :properties => Set(["multimodal", "non-convex", "separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-1.0, -1.0],
        :ub => () -> [1.0, 1.0],
        :description => "Giunta function: Multimodal, non-convex, separable, differentiable, bounded, continuous. Minimum: 0.06447 at [0.46732, 0.46732]. Bounds: [-1, 1]^2. Dimensions: n=2.",
        :math => "0.6 + \\sum_{i=1}^2 \\left[ \\sin\\left(\\frac{16}{15}x_i - 1\\right) + \\sin^2\\left(\\frac{16}{15}x_i - 1\\right) + \\frac{1}{50} \\sin\\left(4 \\left(\\frac{16}{15}x_i - 1\\right)\\right) \\right]"
    )
)
