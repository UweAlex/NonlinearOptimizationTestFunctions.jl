# src/functions/adjiman.jl
# Purpose: Implementation of the Adjiman test function.
# Global minimum: f(x*)=-2.021806783359787 at x*=[2.0, 0.10578347].
# Bounds: -1.0 ≤ x_1 ≤ 2.0, -1.0 ≤ x_2 ≤ 1.0.

export ADJIMAN_FUNCTION, adjiman, adjiman_gradient

function adjiman(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("adjiman requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    cos(x1) * sin(x2) - x1 / (x2^2 + 1)
end

function adjiman_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("adjiman requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    grad[1] = -sin(x1) * sin(x2) - 1 / (x2^2 + 1)
    grad[2] = cos(x1) * cos(x2) + x1 * 2 * x2 / (x2^2 + 1)^2
    grad
end

const ADJIMAN_FUNCTION = TestFunction(
    adjiman,
    adjiman_gradient,
    Dict{Symbol, Any}(
        :name => "adjiman",
        :description => "Properties based on Jamil & Yang (2013, p. 3); Multimodal, non-convex, non-separable, differentiable, bounded test function with a single global minimum.",
        :math => raw"""f(\mathbf{x}) = \cos x_1 \sin x_2 - \frac{x_1}{x_2^2 + 1}.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [2.0, 0.10578347],
        :min_value => () -> -2.021806783359787,
        :properties => ["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"],
        :source => "Jamil & Yang (2013, p. 3)",
        :lb => () -> [-1.0, -1.0],
        :ub => () -> [2.0, 1.0],
    )
)

# Optional: Validierung beim Laden
@assert "adjiman" == basename(@__FILE__)[1:end-3] "adjiman: Dateiname mismatch!"