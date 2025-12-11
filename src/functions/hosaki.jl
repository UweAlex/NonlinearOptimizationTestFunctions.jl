# src/functions/hosaki.jl
# Purpose: Implementation of the Hosaki test function.
# Context: Non-scalable, 2D, from Jamil & Yang (2013), function 66.
# Global minimum: f(x*)=-2.3458 at x*=[4, 2].
# Bounds: 0 <= x1 <= 5, 0 <= x2 <= 6.
# Last modified: September 26, 2025.
# Properties based on Jamil & Yang (2013).

export HOSAKI_FUNCTION, hosaki, hosaki_gradient

function hosaki(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Hosaki requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    p = one(T) - T(8)*x1 + T(7)*x1^2 - T(7)/T(3)*x1^3 + T(1)/T(4)*x1^4
    q = x2^2 * exp(-x2)
    p * q
end

function hosaki_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Hosaki requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    p = one(T) - T(8)*x1 + T(7)*x1^2 - T(7)/T(3)*x1^3 + T(1)/T(4)*x1^4
    dp = -T(8) + T(14)*x1 - T(7)*x1^2 + x1^3
    q = x2^2 * exp(-x2)
    dq = x2 * exp(-x2) * (T(2) - x2)
    
    grad = zeros(T, 2)
    grad[1] = dp * q
    grad[2] = p * dq
    grad
end

const HOSAKI_FUNCTION = TestFunction(
    hosaki,
    hosaki_gradient,
    Dict(
        :name => "hosaki",
        :description => "The Hosaki function, a 2D multimodal non-separable function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left(1 - 8x_1 + 7x_1^2 - \frac{7}{3}x_1^3 + \frac{1}{4}x_1^4\right) x_2^2 e^{-x_2}.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [4.0, 2.0],
        :min_value => () -> -2.345811576101292,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [5.0, 6.0],
    )
)