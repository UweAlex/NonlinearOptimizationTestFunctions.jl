# src/functions/sixhumpcamelback.jl
# Purpose: Implements the Six-Hump Camelback test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 19 July 2025

export SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback, sixhumpcamelback_gradient

using LinearAlgebra
using ForwardDiff

"""
    sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Six-Hump Camelback function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function sixhumpcamelback(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return (4 - 2.1 * x1^2 + x1^4 / 3) * x1^2 + x1 * x2 + (-4 + 4 * x2^2) * x2^2
end

"""
    sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Six-Hump Camelback function. Returns a vector of length 2.
"""
function sixhumpcamelback_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    grad1 = (8 - 8.4 * x1^2 + 2 * x1^4) * x1 + x2
    grad2 = x1 + (-8 + 16 * x2^2) * x2
    return [grad1, grad2]
end

const SIXHUMPCAMELBACK_FUNCTION = TestFunction(
    sixhumpcamelback,
    sixhumpcamelback_gradient,
    Dict(
        :name => "sixhumpcamelback",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
            [-0.08984201368301331, 0.7126564032704135]  # Precise minimum
        end,
        :min_value => -1.031628453489877,  # Precise value
        :properties => Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
            [-3.0, -2.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Six-Hump Camelback requires exactly 2 dimensions"))
            [3.0, 2.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Six-Hump Camelback function: Multimodal with six local minima, two of which are global. Defined for n=2 only.",
        :math => "(4 - 2.1 x₁² + x₁⁴/3) x₁² + x₁ x₂ + (-4 + 4 x₂²) x₂²"
    )
)