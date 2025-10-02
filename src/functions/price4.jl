# src/functions/price4.jl
# Purpose: Implementation of the Price 4 test function (Jamil & Yang, 2013, No. 97).
# Global minimum: f(x*)=0 at x*=(0, 0) and x*=(2, 4).
# Bounds: -500 ≤ x_i ≤ 500.
# Properties: continuous, differentiable, non-separable, multimodal, bounded.
# Last modified: October 01, 2025.

export PRICE4_FUNCTION, price4, price4_gradient

function price4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price 4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    let
        x1, x2 = x[1], x[2]
        u = 2 * x1^3 * x2 - x2^3
        v = 6 * x1 - x2^2 + x2
        u^2 + v^2
    end
end

function price4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Price 4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    let
        x1, x2 = x[1], x[2]
        u = 2 * x1^3 * x2 - x2^3
        v = 6 * x1 - x2^2 + x2
        grad = zeros(T, 2)
        @inbounds begin
            grad[1] = 2 * u * (6 * x1^2 * x2) + 2 * v * 6
            grad[2] = 2 * u * (2 * x1^3 - 3 * x2^2) + 2 * v * (-2 * x2 + 1)
        end
        grad
    end
end

const PRICE4_FUNCTION = TestFunction(
    price4,
    price4_gradient,
    Dict(
        :name => "price4",
        :description => "Price 4 function from Jamil & Yang (2013, No. 97). Properties: continuous, differentiable, non-separable, multimodal, bounded. Multiple minima at (0, 0) and (2, 4).",
        :math => raw"f(\mathbf{x}) = (2x_1^3 x_2 - x_2^3)^2 + (6x_1 - x_2^2 + x_2)^2",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],  # Eines der Minima
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013), https://arxiv.org/abs/1308.4008",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)