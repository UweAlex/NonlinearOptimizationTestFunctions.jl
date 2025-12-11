# src/functions/chenbird.jl
# =============================================================================
# chenbird – the ESTABLISHED BUT INCORRECT Chen V function (Jamil & Yang 2013, f32)
# This is the version used in >95% of all papers since 2013.
# Global minimum ≈ -2000.004 at eight points near (±0.5, ±0.5)
# Bounds: -500 ≤ x_i ≤ 500
# Last modified: 24 November 2025
# =============================================================================

export CHENBIRD_FUNCTION, chenbird, chenbird_gradient

function chenbird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("chenbird requires exactly 2 dimensions"))
    any(isnan, x) && return T(NaN)
    any(isinf, x) && return T(Inf)

    T <: BigFloat && setprecision(256)

    x1, x2 = x
    c  = T(0.001)
    c² = c * c
    r² = x1*x1 + x2*x2

    term1 = c / (c² + (r² - one(T))^2)
    term2 = c / (c² + (r² - T(0.5))^2)
    term3 = c / (c² + (x1*x1 - x2*x2)^2)

    return -(term1 + term2 + term3)
end

function chenbird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("chenbird requires exactly 2 dimensions"))
    any(isnan, x) && return fill(T(NaN), 2)
    any(isinf, x) && return fill(T(Inf), 2)

    T <: BigFloat && setprecision(256)

    x1, x2 = x
    c  = T(0.001)
    c² = c * c
    r² = x1*x1 + x2*x2

    u1 = r² - one(T);   d1 = c² + u1*u1;   d1sq = d1*d1
    u2 = r² - T(0.5);   d2 = c² + u2*u2;   d2sq = d2*d2
    u3 = x1*x1 - x2*x2; d3 = c² + u3*u3;   d3sq = d3*d3

    g1 = T(4)*c*u1*x1 / d1sq + T(4)*c*u2*x1 / d2sq + T(4)*c*u3*x1 / d3sq
    g2 = T(4)*c*u1*x2 / d1sq + T(4)*c*u2*x2 / d2sq - T(4)*c*u3*x2 / d3sq

    return T[g1, g2]
end

const CHENBIRD_FUNCTION = TestFunction(
    chenbird,
    chenbird_gradient,
    Dict{Symbol, Any}(
        :name         => "chenbird",
        :description  => "Chen V function – Jamil & Yang (2013, f32). The version used in >95% of all papers. Three radial terms. Global minimum ≈ -2000.004. This is NOT the original Chen (2003) function!",
        :math         => raw"f(\mathbf{x}) = -\left[ \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 1)^2} + \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 0.5)^2} + \frac{0.001}{(0.001)^2 + (x_1^2 - x_2^2)^2} \right]",
        :start        => () -> [400.0, 400.0],
        :min_position => () -> [0.5, 0.5],
       :min_value => () -> -2000.0039999840003,
        :properties   => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source       => "Jamil & Yang (2013, p. 47)",
        :lb           => () -> [-500.0, -500.0],
        :ub           => () -> [ 500.0,  500.0],
    )
)

