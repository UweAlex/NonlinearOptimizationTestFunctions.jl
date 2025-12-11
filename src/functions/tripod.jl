# src/functions/tripod.jl
# Purpose: Implementation of the Tripod test function.
# Global minimum: f(x*)=0.0 at x*=[0.0, -50.0].
# Bounds: -100 ≤ x_i ≤ 100.

export TRIPOD_FUNCTION, tripod, tripod_gradient

function tripod(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("tripod requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    p1 = x1 >= zero(T) ? one(T) : zero(T)
    p2 = x2 >= zero(T) ? one(T) : zero(T)
    a = x1 + 50 * p2 * (1 - 2 * p1)
    b = x2 + 50 * (1 - 2 * p2)
    p2 * (1 + p1) + abs(a) + abs(b)
end

function tripod_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("tripod requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x
    p1 = x1 >= zero(T) ? one(T) : zero(T)
    p2 = x2 >= zero(T) ? one(T) : zero(T)
    a = x1 + 50 * p2 * (1 - 2 * p1)
    b = x2 + 50 * (1 - 2 * p2)
    g1 = sign(a)
    g2 = sign(b)
    [g1, g2]
end

const TRIPOD_FUNCTION = TestFunction(
    tripod,
    tripod_gradient,
    Dict(
        :name => "tripod",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "The Tripod function is a discontinuous, non-differentiable, non-separable multimodal benchmark with a tripod-shaped surface due to absolute values and step functions. Properties based on Jamil & Yang (2013, p. 37); contains step functions leading to discontinuities and absolute values causing non-differentiability.",
        :math => raw"""f(\mathbf{x}) = p(x_2)(1 + p(x_1)) + |x_1 + 50 p(x_2)(1 - 2 p(x_1))| + |x_2 + 50(1 - 2 p(x_2))|, \\ \text{where } p(x) = \begin{cases} 1 & x \geq 0 \\ 0 & x < 0 \end{cases}.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, -50.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "multimodal", "non-separable", "partially differentiable"],
        :source => "Jamil & Yang (2013, p. 37)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)

# Optional: Validierung beim Laden
