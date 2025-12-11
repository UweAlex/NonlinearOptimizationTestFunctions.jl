# src/functions/rump.jl
# Purpose: Implementation of the Rump test function (Al-Roomi modified version).
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0].
# Bounds: -500.0 ≤ x_i ≤ 500.0.

export RUMP_FUNCTION, rump, rump_gradient

function rump(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rump requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    x1 = x[1]
    x2 = x[2]
    inner = (333.75 - x1^2) * x2^6 +
            x1^2 * (11 * x1^2 * x2^2 - 121 * x2^4 - 2) +
            5.5 * x2^8 +
            x1 / (2 + x2)

    abs(inner)
end


function rump_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("rump requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    x1 = x[1]
    x2 = x[2]
    denom = 2 + x2

    # inner expression
    term1 = (333.75 - x1^2) * x2^6
    term2 = x1^2 * (11 * x1^2 * x2^2 - 121 * x2^4 - 2)
    term3 = 5.5 * x2^8
    term4 = x1 / denom
    inner = term1 + term2 + term3 + term4

    # Not differentiable where inner = 0
    if abs(inner) < eps(T)
        # Return NaN-gradient instead of throwing ArgumentError
        return fill(T(NaN), n)
    end

    sign_inner = sign(inner)

    # ∂inner/∂x1
    dterm1_dx1 = -2 * x1 * x2^6
    dterm2_dx1 = 2 * x1 * (11 * x1^2 * x2^2 - 121 * x2^4 - 2) +
                 22 * x1^3 * x2^2
    dterm3_dx1 = zero(T)
    dterm4_dx1 = 1 / denom
    dg_dx1 = dterm1_dx1 + dterm2_dx1 + dterm3_dx1 + dterm4_dx1

    # ∂inner/∂x2
    dterm1_dx2 = (333.75 - x1^2) * 6 * x2^5
    dterm2_dx2 = x1^2 * (22 * x1^2 * x2 - 484 * x2^3)
    dterm3_dx2 = 44 * x2^7
    dterm4_dx2 = -x1 / denom^2
    dg_dx2 = dterm1_dx2 + dterm2_dx2 + dterm3_dx2 + dterm4_dx2

    grad = zeros(T, 2)
    grad[1] = sign_inner * dg_dx1
    grad[2] = sign_inner * dg_dx2
    grad
end


const RUMP_FUNCTION = TestFunction(
    rump,
    rump_gradient,
    Dict(
        :name => "rump",
        :description => "The Rump function modified for optimization benchmarks: absolute value ensures non-negativity (global min 0), and denominator 2 + x_2 avoids division by zero. Adapted from original Moore (1988) via Jamil & Yang (2013). Properties based on Al-Roomi (2015).",
        :math => raw"""f(\mathbf{x}) = \left| (333.75 - x_1^2) x_2^6 + x_1^2 (11 x_1^2 x_2^2 - 121 x_2^4 - 2) + 5.5 x_2^8 + \frac{x_1}{2 + x_2} \right|.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "partially differentiable", "non-separable", "unimodal"],
        :properties_source => "Al-Roomi (2015)",
        :source => "https://al-roomi.org/benchmarks/unconstrained/2-dimensions/128-rump-function",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)
