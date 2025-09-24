# src/functions/chenv.jl
# Purpose: Implementation of the Chen V test function.
# Context: Non-scalable (n=2), from Chen (2003) via Jamil & Yang (2013).
#          Continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*) ≈ -2000.0039999840005 at x* ≈ (0.500000000004, 0.500000000004)
#                 (and 7 symmetric equivalents in other sign combinations and near (±1/√2, ±1/√2)).
# Bounds: -500 ≤ x_i ≤ 500.
# Last modified: September 23, 2025.

# NOTE: Due to the small constant c=0.001, the function has extremely sharp valleys.
#       Critical points are perturbed from geometric intersections by ~10^{-12}.
#       In Float64, gradient norm at adjusted points is ~10^{-7}, acceptable for most tests.
#       Literature values (e.g., -2000 at (-0.389, 0.722)) appear inconsistent with this formula;
#       verified via high-precision solving of ∇f=0.

export CHENV_FUNCTION, chenv, chenv_gradient

"""
    chenv(x::AbstractVector{T}) where {T<:Real}

Chen V test function (2D). Formula with three terms using c=0.001.
"""
function chenv(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Chen V function requires exactly 2 dimensions"))
    any(isnan, x) && return T(NaN)
    any(isinf, x) && return T(Inf)

    x1, x2 = x[1], x[2]
    c = T(0.001)
    c2 = c * c

    u1 = x1^2 + x2^2 - one(T)
    u2 = x1^2 + x2^2 - T(0.5)
    u3 = x1^2 - x2^2

    return -c / (c2 + u1^2) - c / (c2 + u2^2) - c / (c2 + u3^2)
end

"""
    chenv_gradient(x::AbstractVector{T}) where {T<:Real}

Analytical gradient (2-element vector).
"""
function chenv_gradient(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Chen V function requires exactly 2 dimensions"))
    any(isnan, x) && return fill(T(NaN), 2)
    any(isinf, x) && return fill(T(Inf), 2)

    x1, x2 = x[1], x[2]
    c = T(0.001)
    c2 = c * c

    u1 = x1^2 + x2^2 - one(T)
    d1 = c2 + u1^2
    d1sq = d1 * d1

    u2 = x1^2 + x2^2 - T(0.5)
    d2 = c2 + u2^2
    d2sq = d2 * d2

    u3 = x1^2 - x2^2
    d3 = c2 + u3^2
    d3sq = d3 * d3

    grad = zeros(T, 2)
    tx1 = 2 * x1
    tx2 = 2 * x2

    # Contributions (full 4c via 2c * 2x)
    grad[1] += 2 * c * u1 * tx1 / d1sq
    grad[2] += 2 * c * u1 * tx2 / d1sq

    grad[1] += 2 * c * u2 * tx1 / d2sq
    grad[2] += 2 * c * u2 * tx2 / d2sq

    grad[1] += 2 * c * u3 * tx1 / d3sq
    grad[2] += 2 * c * u3 * (-tx2) / d3sq

    return grad
end

const CHENV_FUNCTION = TestFunction(
    chenv,
    chenv_gradient,
    Dict(
        :name => "chenv",
        :description => "Chen V function from Chen (2003). Continuous, differentiable, non-separable, multimodal with three overlapping terms creating complex landscape.",
        :math => raw"f(\mathbf{x}) = -\frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 1)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 0.5)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 - x_2^2)^2}",
        :start => () -> [0.0, 0.0],
        :min_position => () -> let δ = 4e-12; [0.5 + δ, 0.5 + δ] end,  # Precise stationary point (one of 8); grad norm ≈ 3e-7 in Float64
        :min_value => () -> -2000.0039999840005,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0]
    )
)