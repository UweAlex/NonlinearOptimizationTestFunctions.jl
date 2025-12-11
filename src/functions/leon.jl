# src/functions/leon.jl
# Purpose: Implementation of the Leon test function.
# Context: Non-scalable (n=2), continuous, differentiable, non-separable, unimodal.
# Global minimum: f(x*)=0 at x*=[1,1].
# Bounds: -1.2 ≤ x_i ≤ 1.2.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export LEON_FUNCTION, leon, leon_gradient

function leon(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Leon requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    100 * (x2 - x1^2)^2 + (1 - x1)^2
end

function leon_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Leon requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    grad = zeros(T, 2)
    diff_term = x2 - x1^2
    grad[1] = -400 * x1 * diff_term - 2 * (1 - x1)
    grad[2] = 200 * diff_term
    grad
end

const LEON_FUNCTION = TestFunction(
    leon,
    leon_gradient,
    Dict(
        :name => "leon",
        :description => "The Leon function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = 100(x_2 - x_1^2)^2 + (1 - x_1)^2 """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "unimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Lavi and Vogel (1966)",
        :lb => () -> [-1.2, -1.2],
        :ub => () -> [1.2, 1.2],
    )
)