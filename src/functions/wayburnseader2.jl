# src/functions/wayburnseader2.jl
# Purpose: Implementation of the Wayburn Seader 2 test function.
# Global minimum: f(x*)=0 at x*=(0.2,1) and (0.425,1).
# Bounds: -500 ≤ x_i ≤ 500.

export WAYBURNSEADER2_FUNCTION, wayburnseader2, wayburnseader2_gradient

function wayburnseader2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    x1, x2 = x[1], x[2]
    a = x1 - 0.3125
    b = x2 - 1.625
    inner = 1.613 - 4 * a^2 - 4 * b^2
    inner^2 + (x2 - 1)^2
end

function wayburnseader2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    x1, x2 = x[1], x[2]
    a = x1 - 0.3125
    b = x2 - 1.625
    inner = 1.613 - 4 * a^2 - 4 * b^2
    grad[1] = 2 * inner * (-8 * a)
    grad[2] = 2 * inner * (-8 * b) + 2 * (x2 - 1)
    grad
end

const WAYBURNSEADER2_FUNCTION = TestFunction(
    wayburnseader2,
    wayburnseader2_gradient,
    Dict{Symbol, Any}(
        :name => "wayburnseader2",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Wayburn Seader 2 function. Properties based on Jamil & Yang (2013, p. 63); multiple global minima at (0.2,1) and (0.425,1); originally from Wayburn & Seader (1987). Formula only uses first 2 variables; marked as scalable in source but adapted to fixed n=2 due to limited metadata for higher dimensions. Listed as unimodal in source despite multiple minima; added controversial.",
        :math => raw"""f(\mathbf{x}) = \left[ 1.613 - 4(x_1 - 0.3125)^2 - 4(x_2 - 1.625)^2 \right]^2 + (x_2 - 1)^2.""",
        :start => () -> [-5.0, -5.0],
  :min_position => () -> [0.200138974079519, 1.000000000083411],
  :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "controversial", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 63)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)

# Optional: Validierung beim Laden
@assert "wayburnseader2" == basename(@__FILE__)[1:end-3] "wayburnseader2: Dateiname mismatch!"