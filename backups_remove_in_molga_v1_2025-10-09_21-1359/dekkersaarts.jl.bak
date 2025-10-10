# src/functions/dekkersaarts.jl
# Purpose: Implements the Dekkers-Aarts test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 26 August 2025

using LinearAlgebra
using ForwardDiff

function dekkersaarts(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Dekkers-Aarts requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    s = x[1]^2 + x[2]^2
    return 1e5 * x[1]^2 + x[2]^2 - s^2 + 1e-5 * s^4
end #function

function dekkersaarts_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Dekkers-Aarts requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    s = x[1]^2 + x[2]^2
    c = (8e-5)*s^3 - 4*s

    return T.([x[1]*(2e5 + c), x[2]*(2 + c)])
end #function

const DEKKERSAARTS_FUNCTION = TestFunction(
    dekkersaarts,
    dekkersaarts_gradient,
    Dict(
        :name => "dekkersaarts",
        :start => () -> [0.0, 10.0],
        :min_position => () ->  [0.0, 14.945112151891959],
        :min_value => () ->  -24776.518342317686,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-20.0, -20.0],
        :ub => () -> [20.0, 20.0],
        :description => "Dekkers-Aarts function: Multimodal with two global minima at [0, ±14.94511215174121]. Literature (Ali et al., 2005) reports minima at (0, ±15), f* ≈ -24777, but exact minima are at (0, ±14.94511215174121), f* ≈ -24776.51834231769.",
        :math => "10^5 x_1^2 + x_2^2 - (x_1^2 + x_2^2)^2 + 10^{-5} (x_1^2 + x_2^2)^4"
    )
)

export DEKKERSAARTS_FUNCTION, dekkersaarts, dekkersaarts_gradient