# src/functions/quintic.jl
# Purpose: Implementation of the Quintic test function.
# Global minimum: f(x*)=0 at x*=(-1, -1) (or mixtures of -1 and 2 per dimension).
# Bounds: -10 <= x_i <= 10.

export QUINTIC_FUNCTION, quintic, quintic_gradient

function quintic(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Quintic requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_abs = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        inner = xi^5 - 3*xi^4 + 4*xi^3 + 2*xi^2 - 10*xi - 4
        sum_abs += abs(inner)
    end
    sum_abs
end

function quintic_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Quintic requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        xi = x[i]
        inner = xi^5 - 3*xi^4 + 4*xi^3 + 2*xi^2 - 10*xi - 4
        if isapprox(inner, zero(T), atol=eps(T))
            grad[i] = zero(T)
        else
            poly_deriv = 5*xi^4 - 12*xi^3 + 12*xi^2 + 4*xi - 10
            grad[i] = sign(inner) * poly_deriv
        end
    end
    grad
end

const QUINTIC_FUNCTION = TestFunction(
    quintic,
    quintic_gradient,
    Dict(
        :name => "quintic",
        :description => "The Quintic function is a separable multimodal benchmark function with absolute value terms on a quintic polynomial per dimension. Note: Due to the absolute value, it is not strictly differentiable at the roots of the inner polynomial (x_i = -1 or 2), but a subgradient is provided. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D |x_i^5 - 3x_i^4 + 4x_i^3 + 2x_i^2 - 10x_i - 4|.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-1.0, -1.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "separable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)