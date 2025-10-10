# src/functions/rotatedellipse2.jl
# Purpose: Implementation of the Rotated Ellipse 2 test function.
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0].
# Bounds: -500.0 ≤ x_i ≤ 500.0.

export ROTATEDELLIPSE2_FUNCTION, rotatedellipse2, rotatedellipse2_gradient

function rotatedellipse2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("RotatedEllipse2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1 = x[1]
    x2 = x[2]
    x1^2 - x1 * x2 + x2^2
end

function rotatedellipse2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("RotatedEllipse2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1 = x[1]
    x2 = x[2]
    grad[1] = 2 * x1 - x2
    grad[2] = -x1 + 2 * x2
    grad
end

const ROTATEDELLIPSE2_FUNCTION = TestFunction(
    rotatedellipse2,
    rotatedellipse2_gradient,
    Dict(
        :name => "rotatedellipse2",
        :description => "The Rotated Ellipse 2 function is a unimodal quadratic function. Properties based on Jamil & Yang (2013). It is convex, as the Hessian matrix [[1, -0.5]; [-0.5, 1]] is positive definite with eigenvalues 0.5 and 1.5.",
        :math => raw"""f(\mathbf{x}) = x_1^2 - x_1 x_2 + x_2^2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal", "convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "https://arxiv.org/abs/1308.4008",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)