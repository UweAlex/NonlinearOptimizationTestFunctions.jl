# src/functions/bukin2.jl
# Purpose: Implementation of the Bukin Function N.2 (Bukin 2)
# Global minimum: f(x*) = 0.0 at x* = (-10.0, 1.0)
# Bounds: -15 ≤ x₁ ≤ -5, -3 ≤ x₂ ≤ 3
# Source: Jamil & Yang (2013, p. 34), adapted from Bukin (1995)
# Last modified: 24 November 2025

export BUKIN2_FUNCTION, bukin2, bukin2_gradient

function bukin2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    T <: BigFloat && setprecision(256)

    x1, x2 = x[1], x[2]
    return 100 * (x2 - 0.01 * x1^2)^2 + 0.01 * abs(x1 + 10)
end

function bukin2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    T <: BigFloat && setprecision(256)

    x1, x2 = x[1], x[2]
    # Beachten Sie, dass der Gradient an der Singularität x₁ = -10 nicht definiert ist,
    # aber für Optimierer, die Subableitungen verwenden (z.B. Subgradientenmethoden),
    # kann sign(x1 + 10) verwendet werden.
    g1 = 200 * (x2 - 0.01 * x1^2) * (-0.02 * x1) + 0.01 * sign(x1 + 10)
    g2 = 200 * (x2 - 0.01 * x1^2)
    return T[g1, g2]
end

const BUKIN2_FUNCTION = TestFunction(
    bukin2,
    bukin2_gradient,
    Dict{Symbol, Any}(
        :name         => "bukin2",
        :description  => "Bukin Function N.2. Highly multimodal with a narrow curving ridge. Contains absolute value → not differentiable at x₁ = -10. Global minimum = 0 at (-10, 1).",
        :math         => raw"""f(\mathbf{x}) = 100 (x_2 - 0.01 x_1^2)^2 + 0.01 |x_1 + 10|""",
        :start        => () -> [-12.0, 2.5],   # Innerhalb Bounds, weit weg vom Minimum
        :min_position => () -> [-10.0, 1.0],
        :min_value    => () -> 0.0,
        :properties   => ["bounded", "continuous", "multimodal", "non-separable"],
        :source       => "Jamil & Yang (2013, p. 34)",
        :lb           => () -> [-15.0, -3.0],
        :ub           => () -> [-5.0,   3.0],
    )
)

# Validierung beim Laden
@assert "bukin2" == basename(@__FILE__)[1:end-3] "bukin2: Dateiname mismatch!"