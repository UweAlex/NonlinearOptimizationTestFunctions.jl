# src/functions/bohachevsky3.jl
# Purpose: Implementation of the Bohachevsky 3 test function.
# Global minimum: f(x*)=0 at x*=[0,0].
# Bounds: -100 ≤ x_i ≤ 100.
# Source: Bohachevsky et al. (1986), also listed as f19 in Jamil & Yang (2013, p. 11).

export BOHACHEVSKY3_FUNCTION, bohachevsky3, bohachevsky3_gradient

function bohachevsky3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bohachevsky3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    x1^2 + 2*x2^2 - 0.3*cos(3π*x1 + 4π*x2) + 0.3
end

function bohachevsky3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bohachevsky3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    sin_term = sin(3π*x1 + 4π*x2)
    g1 = 2*x1 + 0.3*3π*sin_term
    g2 = 4*x2 + 0.3*4π*sin_term
    [g1, g2]  # Vector{T} → erfüllt [RULE_GRADTYPE]
end

const BOHACHEVSKY3_FUNCTION = TestFunction(
    bohachevsky3,
    bohachevsky3_gradient,
    Dict{Symbol, Any}(
        :name         => "bohachevsky3",
        :description  => "Bohachevsky 3 function (Bohachevsky et al., 1986). Non-scalable (n=2), non-separable, multimodal test function with global minimum 0 at the origin. Properties based on Jamil & Yang (2013, p. 11).",
        :math         => raw"""f(\mathbf{x}) = x_1^2 + 2 x_2^2 - 0.3 \cos(3 \pi x_1 + 4 \pi x__2) + 0.3.""",
        :start        => () -> [50.0, 50.0],   # weit entfernt vom Minimum → erfüllt [NEW RULE_START_AWAY_FROM_MIN]
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

