# src/functions/bohachevsky2.jl
# Purpose: Implementation of the Bohachevsky 2 test function.
# Global minimum: f(x*)=0 at x*=[0,0].
# Bounds: -100 ≤ x_i ≤ 100.
# Source: Jamil & Yang (2013, p. 11)

export BOHACHEVSKY2_FUNCTION, bohachevsky2, bohachevsky2_gradient

function bohachevsky2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bohachevsky2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    x1^2 + 2*x2^2 - 0.3*cos(3π*x1)*cos(4π*x2) + 0.3
end

function bohachevsky2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bohachevsky2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    g1 = 2*x1 + 0.3*3π*sin(3π*x1)*cos(4π*x2)
    g2 = 4*x2 + 0.3*4π*cos(3π*x1)*sin(4π*x2)
    [g1, g2]                     # Vector{T} → exakt wie in [RULE_GRADTYPE] gefordert
end

const BOHACHEVSKY2_FUNCTION = TestFunction(
    bohachevsky2,
    bohachevsky2_gradient,
    Dict{Symbol, Any}(
        :name         => "bohachevsky2",
        :description  => "Bohachevsky 2 function. Non-scalable (n=2), non-separable, multimodal test function with global minimum 0 at the origin. Properties based on Jamil & Yang (2013, p. 11).",
        :math         => raw"""f(\mathbf{x}) = x_1^2 + 2 x_2^2 - 0.3 \cos(3 \pi x_1) \cos(4 \pi x_2) + 0.3.""",
        :start        => () -> [50.0, 50.0],   # weit weg vom Minimum → [RULE_START_AWAY_FROM_MIN]
        :min_position => () -> [0.0, 0.0],
        :min_value    => () -> 0.0,
        :properties   => [
            "bounded", "continuous", "differentiable",
            "multimodal", "non-convex", "non-separable"
        ],
        :source       => "Jamil & Yang (2013, p. 11)",
        :lb           => () -> [-100.0, -100.0],
        :ub           => () -> [100.0, 100.0],
    )
)

