# src/functions/bohachevsky2.jl
# Purpose: Implements the Bohachevsky 2 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 07 September 2025

export BOHACHEVSKY2_FUNCTION, bohachevsky2, bohachevsky2_gradient

using LinearAlgebra
using ForwardDiff

function bohachevsky2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return x1^2 + 2*x2^2 - 0.3*cos(3π*x1)*cos(4π*x2) + 0.3
end

function bohachevsky2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    g1 = 2*x1 + 0.9*π*sin(3π*x1)*cos(4π*x2)
    g2 = 4*x2 + 1.2*π*cos(3π*x1)*sin(4π*x2)
    return [g1, g2]
end

const BOHACHEVSKY2_FUNCTION = TestFunction(
    bohachevsky2,
    bohachevsky2_gradient,
    Dict(
        :name => "bohachevsky2",
        :start => () -> [0.01, 0.01],
        :min_position => () -> [0.0, 0.0],
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Bohachevsky 2 function: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0, 0). Bounds: [-100, 100]^2.",
        :math => "f(x) = x_1^2 + 2x_2^2 - 0.3\\cos(3\\pi x_1)\\cos(4\\pi x_2) + 0.3"
    )
)
