# src/functions/braninrcos2.jl
# Purpose: Implementation of the Branin RCOS 2 test function (Muntenau & Lazarescu, 1998).
# Global minimum: f(x*) ≈ -39.19565391798 at x* ≈ [-3.172104, 12.585675].
# Bounds: -5 ≤ x₁,x₂ ≤ 15.
# Last modified: 24 November 2025

export BRANINRCOS2_FUNCTION, braninrcos2, braninrcos2_gradient

function braninrcos2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("braninrcos2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    π_val = T(π)
    a = T(5.1) / (4 * π_val^2)
    b = T(5) / π_val

    A = x2 - a * x1^2 + b * x1 - 6
    r2 = x1^2 + x2^2
    ln_term = log(r2 + 1)
    cos_term = (1 - 1/(8*π_val)) * cos(x1) * cos(x2) * ln_term

    return A^2 + 10 * cos_term + 10
end

function braninrcos2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("braninrcos2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    if T <: BigFloat
        setprecision(256)
    end

    x1, x2 = x
    π_val = T(π)
    a = T(5.1) / (4 * π_val^2)
    b = T(5) / π_val

    A = x2 - a * x1^2 + b * x1 - 6
    dA_dx1 = -2*a*x1 + b
    dA_dx2 = one(T)

    r2 = x1^2 + x2^2
    ln_term = log(r2 + 1)
    d_ln_dx1 = 2*x1 / (r2 + 1)
    d_ln_dx2 = 2*x2 / (r2 + 1)

    B = 1 - 1/(8*π_val)
    cos_prod = cos(x1) * cos(x2)
    d_cos_prod_dx1 = -sin(x1) * cos(x2)
    d_cos_prod_dx2 = cos(x1) * -sin(x2)

    d_cos_term_dx1 = B * (d_cos_prod_dx1 * ln_term + cos_prod * d_ln_dx1)
    d_cos_term_dx2 = B * (d_cos_prod_dx2 * ln_term + cos_prod * d_ln_dx2)

    g1 = 2 * A * dA_dx1 + 10 * d_cos_term_dx1
    g2 = 2 * A * dA_dx2 + 10 * d_cos_term_dx2

    return T[g1, g2]
end

const BRANINRCOS2_FUNCTION = TestFunction(
    braninrcos2,
    braninrcos2_gradient,
    Dict{Symbol, Any}(
        :name        => "braninrcos2",
        :description => "Branin RCOS 2 function (Muntenau & Lazarescu, 1998). Multimodal, non-separable test function with a deep global minimum. The original paper reports an incorrect minimum of ≈5.56 – numerical verification yields ≈-39.196.",
        :math        => raw"""f(x_1,x_2) = \left(x_2 - \frac{5.1 x_1^2}{4\pi^2} + \frac{5 x_1}{\pi} - 6\right)^2 + 10\left(1 - \frac{1}{8\pi}\right)\cos(x_1)\cos(x_2)\ln(x_1^2 + x_2^2 + 1) + 10""",
        :start       => () -> [0.0, 10.0],                                   # weit weg vom Minimum
        :min_position=> () -> [-3.1721041516027824, 12.58567479697034],
        :min_value   => () -> -39.19565391797774,
        :properties  => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :source      => "Muntenau & Lazarescu (1998, p. 27)",
        :lb          => () -> [-5.0, -5.0],
        :ub          => () -> [15.0, 15.0],
    )
)

# Validierung beim Laden
