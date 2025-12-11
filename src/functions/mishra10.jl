# src/functions/mishra10.jl
# Purpose: Implementation of the Mishra Function 10 test function.
# Context: Non-scalable, 2D multimodal function from Mishra (2006f), as f83 in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[0,0] or [2,2].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: September 29, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA10_FUNCTION, mishra10, mishra10_gradient

function mishra10(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 10 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    floor_prod = floor(x1 * x2)
    floor_x1 = floor(x1)
    floor_x2 = floor(x2)
    diff = floor_prod - floor_x1 - floor_x2
    return diff * diff
end

function mishra10_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 10 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    # Note: Function is piecewise constant due to floor; gradient is zero almost everywhere
    return zeros(T, 2)
end

const MISHRA10_FUNCTION = TestFunction(
    mishra10,
    mishra10_gradient,
    Dict(
        :name => "mishra10",
        :description => "Mishra Function 10: 2D multimodal function involving floor operations. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left[ \lfloor x_1 x_2 \rfloor - \lfloor x_1 \rfloor - \lfloor x_2 \rfloor \right]^2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f), via Jamil & Yang (2013): f83",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)