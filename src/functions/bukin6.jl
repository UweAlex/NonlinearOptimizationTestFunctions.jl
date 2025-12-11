# src/functions/bukin6.jl
# Purpose: Implementation of the Bukin N.6 test function.
# Global minimum: f(x*)=0 at x*=[-10.0, 1.0].
# Bounds: -15 ≤ x_1 ≤ -5, -3 ≤ x_2 ≤ 3.

export BUKIN6_FUNCTION, bukin6, bukin6_gradient

function bukin6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    u = x2 - 0.01 * x1^2
    v = x1 + 10
    100 * sqrt(abs(u)) + 0.01 * abs(v)
end

function bukin6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bukin6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    u = x2 - 0.01 * x1^2
    v = x1 + 10
    if isapprox(u, 0, atol=1e-10) || isapprox(v, 0, atol=1e-10)
        return fill(T(NaN), n)  # NaN for non-diff points per [RULE_ERROR_HANDLING]
    end
    grad[1] = -x1 * sign(u) / sqrt(abs(u)) + 0.01 * sign(v)
    grad[2] = 50 * sign(u) / sqrt(abs(u))
    grad
end

const BUKIN6_FUNCTION = TestFunction(
    bukin6,
    bukin6_gradient,
    Dict{Symbol, Any}(
        :name => "bukin6",
        :description => "Properties based on Jamil & Yang (2013, p. 10); Contains absolute value and sqrt(abs) terms leading to non-differentiability at certain points (gradient returns NaN there).",
        :math => raw"""f(\mathbf{x}) = 100 \sqrt{|x_2 - 0.01 x_1^2|} + 0.01 |x_1 + 10|.""",
        :start => () -> [-9.0, 0.5],
        :min_position => () -> [-10.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["multimodal", "non-convex", "partially differentiable", "bounded", "continuous"],
        :source => "Jamil & Yang (2013, p. 10)",
        :lb => () -> [-15.0, -3.0],
        :ub => () -> [-5.0, 3.0],
    )
)

# Optional: Validierung beim Laden
