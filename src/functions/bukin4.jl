# src/functions/bukin4.jl
# Purpose: Implementation of the Bukin 4 test function.
# Global minimum: f(x*)=0 at x*=[-10.0, 0.0].
# Bounds: -15 ≤ x_1 ≤ -5, -3 ≤ x_2 ≤ 3.

export BUKIN4_FUNCTION, bukin4, bukin4_gradient

function bukin4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    100 * x2^2 + 0.01 * abs(x1 + 10)
end

function bukin4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    if isapprox(x1 + 10, 0, atol=1e-10)
        return fill(T(NaN), n)  # NaN for non-diff point per [RULE_ERROR_HANDLING]
    end
    grad[1] = 0.01 * sign(x1 + 10)
    grad[2] = 200 * x2
    grad
end

const BUKIN4_FUNCTION = TestFunction(
    bukin4,
    bukin4_gradient,
    Dict{Symbol, Any}(
        :name => "bukin4",
        :description => "Properties based on Jamil & Yang (2013, p. 10); Contains absolute value terms leading to non-differentiability at x1=-10 (gradient returns NaN there).",
        :math => raw"""f(\mathbf{x}) = 100 x_2^2 + 0.01 |x_1 + 10|.""",
        :start => () -> [-5.1, 0.0],
        :min_position => () -> [-10.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "multimodal", "non-convex", "partially differentiable", "separable"],
        :source => "Jamil & Yang (2013, p. 10)",
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],
    )
)

# Optional: Validierung beim Laden
