# src/functions/schaffern4.jl
# Purpose: Implementation of the Schaffer N.4 test function.
# Global minimum: f(x*)=0.292578632035980 at x*=[0.0, 1.253131828792882] (and equivalents).
# Bounds: -100.0 ≤ x_i ≤ 100.0.

export SCHAFFERN4_FUNCTION, schaffern4, schaffern4_gradient

function schaffern4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    x1_sq = x1^2
    x2_sq = x2^2
    diff_sq_abs = abs(x1_sq - x2_sq)
    sin_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_diff)
    numerator = cos_sin^2 - 0.5
    denominator = (1 + 0.001 * (x1_sq + x2_sq))^2
    0.5 + numerator / denominator
end

function schaffern4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffern4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    x1_sq = x1^2
    x2_sq = x2^2
    sum_sq = x1_sq + x2_sq
    diff_sq = x1_sq - x2_sq
    if isapprox(abs(diff_sq), 0, atol=1e-10)
        return fill(T(NaN), n)  # NaN for non-diff point per [RULE_ERROR_HANDLING]
    end
    sign_diff = diff_sq >= 0 ? one(T) : -one(T)
    diff_sq_abs = abs(diff_sq)
    sin_abs_diff = sin(diff_sq_abs)
    cos_sin = cos(sin_abs_diff)
    cos_abs_diff = cos(diff_sq_abs)
    sin_sin = sin(sin_abs_diff)
    denom = 1 + 0.001 * sum_sq
    denom_sq = denom^2
    numerator = cos_sin^2 - 0.5
    cos_sin_term = -2 * cos_sin * sin_sin * cos_abs_diff
    d_num_dx1 = cos_sin_term * sign_diff * 2 * x1
    d_num_dx2 = cos_sin_term * sign_diff * (-2 * x2)
    d_denom_dx1 = 2 * denom * 0.001 * 2 * x1
    d_denom_dx2 = 2 * denom * 0.001 * 2 * x2
    denom_4th = denom_sq^2
    grad[1] = (d_num_dx1 * denom_sq - numerator * d_denom_dx1) / denom_4th
    grad[2] = (d_num_dx2 * denom_sq - numerator * d_denom_dx2) / denom_4th
    grad
end

const SCHAFFERN4_FUNCTION = TestFunction(
    schaffern4,
    schaffern4_gradient,
    Dict{Symbol, Any}(
        :name => "schaffern4",
        :description => "Properties based on Jamil & Yang (2013, p. 27); Adapted for variant with |x₁² - x₂²| from Al-Roomi (2015); Contains abs terms leading to non-differentiability at x₁² = x₂² (gradient returns NaN there).",
        :math => raw"""f(\mathbf{x}) = 0.5 + \frac{\cos^2(\sin(|x_1^2 - x_2^2|)) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}.""",
        :start => () -> [10.0, 10.0],  # Away from min: f≈0.847 > min +0.5
        :min_position => () -> [0.0, 1.253131828792882],
        :min_value => () -> 0.29257863203598033,
        :properties => ["bounded", "continuous", "multimodal", "non-convex", "non-separable", "partially differentiable"],
        :source => "Jamil & Yang (2013, p. 27)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)

# Optional: Validierung beim Laden
@assert "schaffern4" == basename(@__FILE__)[1:end-3] "schaffern4: Dateiname mismatch!"