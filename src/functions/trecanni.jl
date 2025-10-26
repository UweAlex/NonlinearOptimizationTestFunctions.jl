# src/functions/trecanni.jl
# Purpose: Implementation of the Trecanni test function.
# Global minimum: f(x*)=0 at x*=[-2, 0] (and symmetric [0, 0]).
# Bounds: -5 ≤ x_i ≤ 5.

export TRECANNI_FUNCTION, trecanni, trecanni_gradient

function trecanni(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("trecanni requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    f_val = x1^4 + 4 * x1^3 + 4 * x1^2 + x2^2
    f_val
end

function trecanni_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("trecanni requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1, x2 = x[1], x[2]
    grad[1] = 4 * x1^3 + 12 * x1^2 + 8 * x1
    grad[2] = 2 * x2
    grad
end

const TRECANNI_FUNCTION = TestFunction(
    trecanni,
    trecanni_gradient,
    Dict(
        :name => "trecanni",
        :description => "Two global minima at [-2,0] and [0,0]; Properties based on Jamil & Yang (2013, p. 35); originally from Dixon & Szegő (1978).",
        :math => raw"""f(\mathbf{x}) = x_1^4 + 4x_1^3 + 4x_1^2 + x_2^2.""",
        :start => () -> [-1.0, 1.0],
        :min_position => () -> [-2.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "separable"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0],
    )
)

# Optional: Validation on load
@assert "trecanni" == basename(@__FILE__)[1:end-3] "trecanni: Filename mismatch!"