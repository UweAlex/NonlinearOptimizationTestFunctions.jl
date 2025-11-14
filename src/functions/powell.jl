# src/functions/powell.jl
# Purpose: Implementation of the Powell test function.
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0, 0.0, 0.0].
# Bounds: -5.0 ≤ x_i ≤ 5.0.

export POWELL_FUNCTION, powell, powell_gradient

function powell(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("powell requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3, x4 = x
    term1 = (x1 + 10 * x2)^2
    term2 = 5 * (x3 - x4)^2
    term3 = (x2 - 2 * x3)^4
    term4 = 10 * (x1 - x4)^4
    term1 + term2 + term3 + term4
end

function powell_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("powell requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2, x3, x4 = x
    grad = zeros(T, n)
    grad[1] = 2 * (x1 + 10 * x2) + 40 * (x1 - x4)^3
    grad[2] = 20 * (x1 + 10 * x2) + 4 * (x2 - 2 * x3)^3
    grad[3] = 10 * (x3 - x4) - 8 * (x2 - 2 * x3)^3
    grad[4] = -10 * (x3 - x4) - 40 * (x1 - x4)^3
    grad
end

const POWELL_FUNCTION = TestFunction(
    powell,
    powell_gradient,
    Dict{Symbol, Any}(
        :name => "powell",
        :description => "Powell function; Properties based on Jamil & Yang (2013, p. 28); originally from Powell (1962).",
        :math => raw"""f(\mathbf{x}) = (x_1 + 10x_2)^2 + 5(x_3 - x_4)^2 + (x_2 - 2x_3)^4 + 10(x_1 - x_4)^4.""",
        :start => () -> [3.0, -1.0, 0.0, 1.0],
        :min_position => () -> [0.0, 0.0, 0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 28)",
        :lb => () -> fill(-5.0, 4),
        :ub => () -> fill(5.0, 4),
    )
)

# Optional: Validierung beim Laden
@assert "powell" == basename(@__FILE__)[1:end-3] "powell: Dateiname mismatch!"