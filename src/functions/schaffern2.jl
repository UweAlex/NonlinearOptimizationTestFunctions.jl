# src/functions/schaffern2.jl
# Purpose: Implements the Schaffer N.2 test function with its gradient.
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0].
# Bounds: -100.0 ≤ x_i ≤ 100.0.
# Start point: [50.0, 50.0] → NICHT das Minimum!
# Last modified: November 13, 2025.

export SCHAFFERN2_FUNCTION, schaffern2, schaffern2_gradient

using LinearAlgebra

function schaffern2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    x1_sq, x2_sq = x1^2, x2^2
    diff_sq = x1_sq - x2_sq
    sum_sq = x1_sq + x2_sq
    denom = 1 + 0.001 * sum_sq
    denom_sq = denom^2
    
    sin_val = sin(diff_sq)
    numerator = sin_val^2 - 0.5
    
    0.5 + numerator / denom_sq
end

function schaffern2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    x1_sq, x2_sq = x1^2, x2^2
    diff_sq = x1_sq - x2_sq
    sum_sq = x1_sq + x2_sq
    denom = 1 + 0.001 * sum_sq
    denom_sq = denom^2
    denom_4th = denom_sq^2
    
    sin_diff = sin(diff_sq)
    cos_diff = cos(diff_sq)
    numerator = sin_diff^2 - 0.5
    
    # ∂f/∂x1 = [2 * sin * cos * 2*x1 * denom_sq - numerator * 2*denom*0.001*2*x1] / denom^4
    common_term = 2 * sin_diff * cos_diff
    grad1 = (common_term * 2 * x1 * denom_sq - numerator * 2 * denom * 0.001 * 2 * x1) / denom_4th
    grad2 = (common_term * (-2 * x2) * denom_sq - numerator * 2 * denom * 0.001 * 2 * x2) / denom_4th
    
    [grad1, grad2]
end

const SCHAFFERN2_FUNCTION = TestFunction(
    schaffern2,
    schaffern2_gradient,
    Dict{Symbol, Any}(
        :name => "schaffern2",
        :description => "Schaffer N.2 function: A multimodal function with a global minimum at the origin and many local minima. Variant without sqrt in sine argument; Properties based on Mishra (2007, p. 4); originally from Schaffer.",
        :math => raw"""f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 - x_2^2) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}.""",
        :start => () -> [50.0, 50.0],  # GEÄNDERT: NICHT [0.0, 0.0]
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source => "Mishra (2007, p. 4)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)

# Validierung beim Laden
@assert basename(@__FILE__)[1:end-3] == "schaffern2" "schaffern2: Dateiname mismatch!"