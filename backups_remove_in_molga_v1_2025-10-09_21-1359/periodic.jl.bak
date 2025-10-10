# src/functions/periodic.jl
# Purpose: Implementation of the Periodic test function.
# Context: Non-scalable, 2D, multimodal with 49 local minima.
# Global minimum: f(x*)=0.9 at x*=[0.0, 0.0].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: September 30, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export PERIODIC_FUNCTION, periodic, periodic_gradient

function periodic(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("periodic requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    T(1) + sin(x1)^2 + sin(x2)^2 - T(0.1) * exp( -(x1^2 + x2^2) )
end

function periodic_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("periodic requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    grad = zeros(T, 2)
    grad[1] = sin(2 * x1) + T(0.2) * x1 * exp( -(x1^2 + x2^2) )
    grad[2] = sin(2 * x2) + T(0.2) * x2 * exp( -(x1^2 + x2^2) )
    grad
end

const PERIODIC_FUNCTION = TestFunction(
    periodic,
    periodic_gradient,
    Dict(
        :name => "periodic",
        :description => "Periodic function (also known as Price's Function No. 02) with 49 local minima at f=1 and global minimum at origin f=0.9. Non-separable due to coupled exponential term. Properties based on Jamil & Yang (2013), adapted for separability analysis.",
        :math => raw"""f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1 e^{-(x_1^2 + x_2^2)}.""",
        :start => () -> [3.141592653589793, 3.141592653589793],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.9,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Ali et al. (2005)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)