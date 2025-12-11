# src/functions/chenv.jl
# =============================================================================
# Chen V function – the REAL original from Chen (2003)
# Three radial terms – 8 symmetric near-global minima near (±0.5, ±0.5)
# Global minimum ≈ -2000.0039999840005
# Bounds: -500 ≤ x_i ≤ 500
# This is NOT the Jamil & Yang version!
# Last modified: 24 November 2025
# =============================================================================

export CHENV_FUNCTION, chenv, chenv_gradient

function chenv(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("chenv requires exactly 2 dimensions"))
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

    return -(term1 + term2 + term3)   # negated for minimization
end

function chenv_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("chenv requires exactly 2 dimensions"))
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

    return T[g1, g2]   # correct – no extra negation
end

const CHENV_FUNCTION = TestFunction(
    chenv,
    chenv_gradient,
    Dict{Symbol, Any}(
        :name         => "chenv",
        :description  => "Original Chen V function (Chen, 2003). Three radial/hyperbolic terms. Eight symmetric near-global minima near (±0.5, ±0.5). Global minimum ≈ -2000.004. This is the REAL Chen V – not the incorrect linear versions from Jamil & Yang (2013) or others.",
        :math         => raw"f(\mathbf{x}) = -\left[ \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 1)^2} + \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 0.5)^2} + \frac{0.001}{(0.001)^2 + (x_1^2 - x_2^2)^2} \right]",
        :start        => () -> [400.0, 400.0],   # far from origin
        :min_position => () -> [0.5, 0.5],
        :min_value    => () -> -2000.0039999840005,
        :properties   => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source       => "Chen (2003) – original publication",
        :lb           => () -> [-500.0, -500.0],
        :ub           => () -> [ 500.0,  500.0],
    )
)

