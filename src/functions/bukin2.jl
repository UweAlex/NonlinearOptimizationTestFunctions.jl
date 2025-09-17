
# src/functions/bukin2.jl
# Purpose: Implements the Bukin 2 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 07 September 2025, 1:30 PM CEST

export BUKIN2_FUNCTION, bukin2, bukin2_gradient

using LinearAlgebra
using ForwardDiff

function bukin2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    term1 = x2 - 0.01 * x1^2 + 1.0
    return 100.0 * term1^2 + 0.01 * (x1 + 10.0)^2
end

function bukin2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bukin 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    term1 = x2 - 0.01 * x1^2 + 1.0
    g1 = 200.0 * term1 * (-0.02 * x1) + 0.02 * (x1 + 10.0)
    g2 = 200.0 * term1 * 1.0
    return [g1, g2]
end

const BUKIN2_FUNCTION = TestFunction(
    bukin2,
    bukin2_gradient,
    Dict(
        :name => "bukin2",
        :start => () -> [-7.5, 0.0],
        :min_position => () -> [-10.0, 0.0],
        :min_value => () -> 0.0,
        :properties => Set(["bounded","continuous", "differentiable", "multimodal"]),
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],  # Korrigierte obere Schranke für x2
        :in_molga_smutnicki_2005 => false,
        :description => "Bukin 2 function: Continuous, differentiable, non-separable, non-scalable, multimodal. Minimum: 0.0 at (-10.0, 0.0). Bounds: x1 in [-15, -5], x2 in [-3, 3]. Note: Formula corrected with ^2 to match minimum per Jamil & Yang (2013) due to original definition inconsistency.",
        :math => "f(x) = 100 (x_2 - 0.01 x_1^2 + 1)^2 + 0.01 (x_1 + 10)^2"
    )
)
