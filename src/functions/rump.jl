# src/functions/rump.jl
# Purpose: Implementation of the Rump test function (Al-Roomi modified version).
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0].
# Bounds: -500.0 ≤ x_i ≤ 500.0.

export RUMP_FUNCTION, rump, rump_gradient

function rump(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rump requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1 = x[1]
    x2 = x[2]
    inner = (333.75 - x1^2) * x2^6 + x1^2 * (11 * x1^2 * x2^2 - 121 * x2^4 - 2) + 5.5 * x2^8 + x1 / (2 + x2)
    abs(inner)
end

function rump_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rump requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1 = x[1]
    x2 = x[2]
    denom = 2 + x2
    inner = (333.75 - x1^2) * x2^6 + x1^2 * (11 * x1^2 * x2^2 - 121 * x2^4 - 2) + 5.5 * x2^8 + x1 / denom
    
    if inner == zero(T)
        # At points where inner == 0, gradient is zero (subgradient contains 0)
        return grad
    end
    
    sign_inner = sign(inner)
    
    # Partial derivatives of inner
    dg_dx1 = -2 * x1 * x2^6 + (22 * x1^3 * x2^2 - 242 * x1 * x2^4 - 2 * x1^2) + 1 / denom
    dg_dx2 = 6 * (333.75 - x1^2) * x2^5 + x1^2 * (22 * x1^2 * x2 - 484 * x2^3) + 44 * x2^7 - x1 / denom^2
    
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