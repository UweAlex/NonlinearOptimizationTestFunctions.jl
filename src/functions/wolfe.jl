# src/functions/wolfe.jl
# Purpose: Implementation of the Wolfe test function.
# Global minimum: f(x*)=0.0 at x*=[0.0, 0.0, 0.0].
# Bounds: 0.0 ≤ x_i ≤ 2.0.

export WOLFE_FUNCTION, wolfe, wolfe_gradient

function wolfe(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("wolfe requires exactly 3 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # [RULE_HIGH_PREC_SUPPORT]
    end
    
    x1, x2, x3 = x
    u = x1^2 + x2^2 - x1 * x2
    # u >= 0 always (positive semi-definite)
    g = u^0.75
    (4 / 3) * g + x3
end

function wolfe_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("wolfe requires exactly 3 dimensions"))  # Hartkodiert [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, 3)  # [RULE_GRADTYPE]
    x1, x2, x3 = x
    u = x1^2 + x2^2 - x1 * x2
    if u > 1e-12  # Threshold for numerical stability near u=0 (limit grad=0); avoids FP artifacts [NEW: Fix for atol failure]
        u_pow = u^(-0.25)
        factor = (4 / 3) * 0.75 * u_pow
        grad[1] = factor * (2 * x1 - x2)
        grad[2] = factor * (2 * x2 - x1)
    else
        grad[1] = zero(T)
        grad[2] = zero(T)
    end
    grad[3] = one(T)  # df/dx3 = 1
    grad
end

const WOLFE_FUNCTION = TestFunction(
    wolfe,
    wolfe_gradient,
    Dict{Symbol, Any}(
        :name => "wolfe",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "The Wolfe function; Properties based on Al-Roomi (2015) and adapted from Jamil & Yang (2013, p. 39) (partially separable due to x1-x2 coupling in u; unimodal; fixed n=3, not scalable). Contains power term ^{0.75} differentiable at u=0 (grad limit=0).",
        :math => raw"""f(\mathbf{x}) = \frac{4}{3} (x_1^2 + x_2^2 - x_1 x_2)^{0.75} + x_3.""",
        :start => () -> [1.0, 1.0, 1.0],
        :min_position => () -> [0.0, 0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "partially separable", "unimodal"],
        :source => "Al-Roomi (2015); adapted from Jamil & Yang (2013, p. 39)",
        :lb => () -> [0.0, 0.0, 0.0],
        :ub => () -> [2.0, 2.0, 2.0],
    )
)

# Optional: Validierung beim Laden
@assert "wolfe" == basename(@__FILE__)[1:end-3] "wolfe: Dateiname mismatch!"