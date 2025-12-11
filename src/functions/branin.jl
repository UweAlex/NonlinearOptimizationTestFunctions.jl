# src/functions/branin.jl
# Purpose: Implementation of the Branin (or Branin-Hoo) test function.
# Global minimum: f(x*) ≈ 0.39788735772973816 at three known points (only one listed in meta).
# Bounds: x₁ ∈ [-5, 10], x₂ ∈ [0, 15].

export BRANIN_FUNCTION, branin, branin_gradient

function branin(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("branin requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    # Optional high-precision handling
    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    a = 1.0
    b = 5.1 / (4.0 * π^2)
    c = 5.0 / π
    r = 6.0
    s = 10.0
    t = 1.0 / (8.0 * π)

    term1 = a * (x2 - b * x1^2 + c * x1 - r)^2
    term2 = s * (1.0 - t) * cos(x1)
    term1 + term2 + s
end

function branin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("branin requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    a = 1.0
    b = 5.1 / (4.0 * π^2)
    c = 5.0 / π
    r = 6.0
    s = 10.0
    t = 1.0 / (8.0 * π)

    inner = x2 - b * x1^2 + c * x1 - r
    df_dx1 = 2.0 * a * inner * (c - 2.0 * b * x1) - s * (1.0 - t) * sin(x1)
    df_dx2 = 2.0 * a * inner

    T[df_dx1, df_dx2]
end

const BRANIN_FUNCTION = TestFunction(
    branin,
    branin_gradient,
    Dict{Symbol, Any}(
        :name => "branin",                                           # [RULE_NAME_CONSISTENCY]
        :description => "Classic Branin function with three global minima. Properties based on Jamil & Yang (2013, p. 9).",
        :math => raw"""
        f(\mathbf{x}) = a(x_2 - b x_1^2 + c x_1 - r)^2 + s(1-t)\cos(x_1) + s
        \quad\text{with}\quad
        a=1,\; b=\frac{5.1}{4\pi^2},\; c=\frac{5}{\pi},\; r=6,\; s=10,\; t=\frac{1}{8\pi}
        """,
        :start => () -> [0.0, 0.0],                                  # away from any minimum → [RULE_START_AWAY_FROM_MIN]
        :min_position => () -> [-π, 12.275],                        # one of the three global minima
        :min_value => () -> 0.39788735772973816,                    # exact known value
        :lb => () -> [-5.0, 0.0],
        :ub => () -> [10.0, 15.0],
        :properties => ["bounded", "continuous", "differentiable",
                        "multimodal", "non-convex", "non-separable"], # only from VALID_PROPERTIES
        :source => "Jamil & Yang (2013, p. 9)",                     # direct source with page → [RULE_PROPERTIES_SOURCE]
    )
)

# Optional runtime validation
