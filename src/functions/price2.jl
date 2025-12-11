# src/functions/price2.jl
# Purpose: Implementation of the Price Function 2 test function.
# Global minimum: f(x*)=0.9 at x*=(0,0).
# Bounds: -10 ≤ x_i ≤ 10.

export PRICE2_FUNCTION, price2, price2_gradient

function price2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price Function 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    1 + sin(x[1])^2 + sin(x[2])^2 - 0.1 * exp(-x[1]^2 - x[2]^2)
end

function price2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price Function 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    grad = zeros(T, 2)
    
    exp_term = exp(-x[1]^2 - x[2]^2)
    
    # ∂f/∂x₁ = 2sin(x₁)cos(x₁) + 0.1 * 2x₁ * exp(-x₁² - x₂²)
    grad[1] = 2 * sin(x[1]) * cos(x[1]) + 0.2 * x[1] * exp_term
    
    # ∂f/∂x₂ = 2sin(x₂)cos(x₂) + 0.1 * 2x₂ * exp(-x₁² - x₂²)
    grad[2] = 2 * sin(x[2]) * cos(x[2]) + 0.2 * x[2] * exp_term
    
    grad
end

const PRICE2_FUNCTION = TestFunction(
    price2,
    price2_gradient,
    Dict(
        :name => "price2",
        :description => "Price Function 2 (Price, 1977). Properties based on Jamil & Yang (2013). Combines trigonometric and exponential terms.",
        :math => raw"""f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1e^{-x_1^2 - x_2^2}.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.9,
        :properties => ["continuous", "differentiable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Price (1977)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)