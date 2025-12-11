# src/functions/price1.jl
# Purpose: Implementation of the Price Function 1 test function.
# Global minima: f(x*)=0 at x*={(±5,±5)}.
# Bounds: -500 ≤ x_i ≤ 500.

export PRICE1_FUNCTION, price1, price1_gradient

function price1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price Function 1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    (abs(x[1]) - 5)^2 + (abs(x[2]) - 5)^2
end

function price1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price Function 1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    grad = zeros(T, 2)
    
    # ∂f/∂x₁ = 2(|x₁| - 5) * sign(x₁)
    grad[1] = 2 * (abs(x[1]) - 5) * sign(x[1])
    
    # ∂f/∂x₂ = 2(|x₂| - 5) * sign(x₂)
    grad[2] = 2 * (abs(x[2]) - 5) * sign(x[2])
    
    grad
end

const PRICE1_FUNCTION = TestFunction(
    price1,
    price1_gradient,
    Dict(
        :name => "price1",
        :description => "Price Function 1 (Price, 1977). Properties based on Jamil & Yang (2013). Non-differentiable at x=0 due to absolute value terms. Has four global minima at the corners.",
        :math => raw"""f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [5.0, 5.0],  # One of four minima
        :min_value => () -> 0.0,
        :properties => ["continuous", "separable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Price (1977)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)