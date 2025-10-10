# src/functions/rotatedellipse.jl
# Purpose: Implementation of the Rotated Ellipse test function.
# Global minimum: f(x*)=0 at x*=(0, 0).
# Bounds: -500 ≤ x_i ≤ 500.

export ROTATEDELLIPSE_FUNCTION, rotatedellipse, rotatedellipse_gradient

function rotatedellipse(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rotated Ellipse requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # f(x) = 7x₁² - 6√3x₁x₂ + 13x₂²
    x1, x2 = x[1], x[2]
    sqrt3 = T(sqrt(3.0))
    
    result = 7 * x1^2 - 6 * sqrt3 * x1 * x2 + 13 * x2^2
    return result
end

function rotatedellipse_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rotated Ellipse requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    # ∂f/∂x₁ = 14x₁ - 6√3x₂
    # ∂f/∂x₂ = -6√3x₁ + 26x₂
    x1, x2 = x[1], x[2]
    sqrt3 = T(sqrt(3.0))
    
    grad = zeros(T, 2)
    grad[1] = 14 * x1 - 6 * sqrt3 * x2
    grad[2] = -6 * sqrt3 * x1 + 26 * x2
    
    return grad
end

const ROTATEDELLIPSE_FUNCTION = TestFunction(
    rotatedellipse,
    rotatedellipse_gradient,
    Dict(
        :name => "rotatedellipse",
        :description => "Rotated Ellipse function. A convex quadratic function with elliptical contours rotated due to the cross-term. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal", "convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil, M. & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimization problems. Int. Journal of Mathematical Modelling and Numerical Optimisation, 4(2), 150-194.",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)