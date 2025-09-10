# src/functions/bukin4.jl
# Purpose: Implements the Bukin 4 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 10 September 2025

export BUKIN4_FUNCTION, bukin4, bukin4_gradient

using LinearAlgebra
using ForwardDiff

function bukin4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin 4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    return 100 * x2^2 + 0.01 * abs(x1 + 10)
end

function bukin4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin 4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    if iszero(x1 + 10)
        throw(DomainError(x1 + 10, "Gradient undefined at x1 = -10"))
    end
    return [0.01 * sign(x1 + 10), 200 * x2]
end

const BUKIN4_FUNCTION = TestFunction(
    bukin4,
    bukin4_gradient,
    Dict(
        :name => "bukin4",
        :start => () -> [-5.1, 0.0],  # Angepasst, um Grenze zu vermeiden
        :min_position => () -> [-10.0, 0.0],
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "separable", "partially differentiable", "continuous", "bounded"]),
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],
        :description => "Bukin 4 function: Multimodal, non-convex, separable, partially differentiable, bounded, continuous. Has a deep valley along x1 = -10.",
        :math => "f(\\mathbf{x}) = 100 x_2^2 + 0.01 |x_1 + 10|",
        :reference => ["Jamil & Yang (2013): f27", "Naser et al. (2024): 4.39"]
    )
)