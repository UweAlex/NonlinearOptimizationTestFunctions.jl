# src/functions/quadratic.jl
# Purpose: Implementation of the Quadratic test function.
# Global minimum: f(x*)=-3873.72418218627 at x*=[0.193880172788953, 0.485133909126923].
# Bounds: -10 ≤ x_i ≤ 10.

export QUADRATIC_FUNCTION, quadratic, quadratic_gradient

function quadratic(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("quadratic requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    T(-3803.84) - T(138.08)*x1 - T(232.92)*x2 + T(128.08)*x1^2 + T(203.64)*x2^2 + T(182.25)*x1*x2
end

function quadratic_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("quadratic requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x[1], x[2]
    grad = zeros(T, n)
    grad[1] = T(-138.08) + T(256.16)*x1 + T(182.25)*x2
    grad[2] = T(-232.92) + T(182.25)*x1 + T(407.28)*x2
    grad
end

const QUADRATIC_FUNCTION = TestFunction(
    quadratic,
    quadratic_gradient,
    Dict(
        :name => "quadratic",
        :description => "Quadratic function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = -3803.84 - 138.08 x_1 - 232.92 x_2 + 128.08 x_1^2 + 203.64 x_2^2 + 182.25 x_1 x_2.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.193880172788953, 0.485133909126923],
        :min_value => () -> -3873.72418218627,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "convex", "unimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)