# src/functions/bohachevsky3.jl
# Purpose: Implements the Bohachevsky 3 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions. Non-scalable (n=2), from Bohachevsky et al. (1986).
# Global minimum: f(x*)=0 at x*=[0, 0].
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: 23 September 2025.

export BOHACHEVSKY3_FUNCTION, bohachevsky3, bohachevsky3_gradient

function bohachevsky3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return x1^2 + 2 * x2^2 - 0.3 * cos(3 * π * x1 + 4 * π * x2) + 0.3
end

function bohachevsky3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    sin_term = sin(3 * π * x1 + 4 * π * x2)
    g1 = 2 * x1 + 0.3 * 3 * π * sin_term
    g2 = 4 * x2 + 0.3 * 4 * π * sin_term
    return [g1, g2]
end

const BOHACHEVSKY3_FUNCTION = TestFunction(
    bohachevsky3,
    bohachevsky3_gradient,
    Dict(
        :name => "bohachevsky3",
        :description => "Bohachevsky 3 function from Bohachevsky et al. (1986), f19 in Jamil & Yang (2013): Multimodal, differentiable, non-separable test function with a global minimum at (0, 0).",
        :math => raw"""f(\mathbf{x}) = x_1^2 + 2x_2^2 - 0.3 \cos(3\pi x_1 + 4\pi x_2) + 0.3.""",
        :start => () -> [0.01, 0.01],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "multimodal", "non-convex", "non-separable", "bounded"],
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)