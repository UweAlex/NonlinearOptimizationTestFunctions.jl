# src/functions/corana.jl
# Purpose: Implementation of the Corana test function.
# Context: Scalable (n >= 1), discontinuous, non-differentiable, separable, multimodal. Source: Corana et al. (1990), via Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[0,...,0].
# Bounds: -500 <= x_i <= 500.
# Last modified: September 24, 2025.

export CORANA_FUNCTION, corana, corana_gradient

const D_CYCLE = [1.0, 1000.0, 10.0, 100.0]
const S = 0.2
const A_VAL = 0.05
const OFFSET = 0.49999
const FACTOR = 0.05
const COEFF = 0.15

function corana(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:n
        x_i = x[i]
        abs_x_i = abs(x_i)
        k = floor(abs_x_i / S + OFFSET)
        z_i = S * k * sign(x_i)
        v = abs(x_i - z_i)
        d_i = D_CYCLE[mod(i-1, 4) + 1]
        if v < A_VAL
            inner = z_i - FACTOR * sign(z_i)
            term = COEFF * d_i * inner^2
        else
            term = d_i * x_i^2
        end
        total += term
    end
    return total
end

function corana_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        x_i = x[i]
        abs_x_i = abs(x_i)
        k = floor(abs_x_i / S + OFFSET)
        z_i = S * k * sign(x_i)
        v = abs(x_i - z_i)
        d_i = D_CYCLE[mod(i-1, 4) + 1]
        if v < A_VAL
            partial = zero(T)  # Flat region
        else
            partial = 2 * d_i * x_i
        end
        grad[i] = partial
    end
    return grad
end

const CORANA_FUNCTION = TestFunction(
    corana,
    corana_gradient,
    Dict(
        :name => "corana",
        :description => "Corana function (discontinuous, non-differentiable, separable, scalable, multimodal). Source: Corana et al. (1990). Global minimum f(x*)=0 at x*=(0,...,0).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n \begin{cases} 0.15 d_i (z_i - 0.05 \sgn(z_i))^2 & |x_i - z_i| < 0.05 \\ d_i x_i^2 & \text{otherwise} \end{cases}, \\ z_i = 0.2 \left\lfloor \frac{|x_i|}{0.2} + 0.49999 \right\rfloor \sgn(x_i), \\ d_i \text{ cycles over } [1, 1000, 10, 100].""",
        :start => n -> fill(1.0, n),
        :min_position => n -> zeros(n),
        :min_value => n -> 0.0,
        :properties => ["bounded", "multimodal", "separable", "scalable"],
        :default_n => 2,
        :lb => n -> fill(-500.0, n),
        :ub => n -> fill(500.0, n),
    )
)
