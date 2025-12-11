# src/functions/xin_she_yang4.jl
# Purpose: Implementation of the Xin-She Yang No. 4 test function.
# Global minimum: f(x*)=-1.0 at x*=(0, ..., 0) (n-independent).
# Bounds: -10 ≤ x_i ≤ 10.

export XIN_SHE_YANG4_FUNCTION, xin_she_yang4, xin_she_yang4_gradient

function xin_she_yang4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    # Compute terms locally [RULE_NO_CONST_ARRAYS]
    sum_sin_sq = zero(T)
    sum_x_sq = zero(T)
    sum_sin_sqrt_abs = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum_sin_sq += sin(xi)^2
        sum_x_sq += xi^2
        sum_sin_sqrt_abs += sin(sqrt(abs(xi)))^2
    end
    U = sum_sin_sq - exp(-sum_x_sq)
    V = exp(-sum_sin_sqrt_abs)
    U * V
end

function xin_she_yang4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    # Compute shared terms
    sum_sin_sq = zero(T)
    sum_x_sq = zero(T)
    sum_sin_sqrt_abs = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum_sin_sq += sin(xi)^2
        sum_x_sq += xi^2
        sum_sin_sqrt_abs += sin(sqrt(abs(xi)))^2
    end
    U = sum_sin_sq - exp(-sum_x_sq)
    V = exp(-sum_sin_sqrt_abs)
    exp_minus_sum_x_sq = exp(-sum_x_sq)
    @inbounds for k in 1:n
        xk = x[k]
        # ∂U/∂x_k = 2 sin(x_k) cos(x_k) + 2 x_k exp(-sum_x_sq)
        dU_dxk = T(2) * sin(xk) * cos(xk) + T(2) * xk * exp_minus_sum_x_sq
        # ∂V/∂x_k: -V * ∂[sin²(√|x_k|)] / ∂x_k = -V * sin(2 √|x_k|) * (sign(x_k) / (2 √|x_k|))
        if abs(xk) > eps(T)
            sqrt_abs_xk = sqrt(abs(xk))
            d_sin_sqrt_abs_dxk = sin(T(2) * sqrt_abs_xk) * (sign(xk) / (T(2) * sqrt_abs_xk))
            dV_dxk = -V * d_sin_sqrt_abs_dxk
        else
            dV_dxk = zero(T)  # At 0: 0 (no div-by-zero)
        end
        grad[k] = dU_dxk * V + U * dV_dxk  # Produktregel [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const XIN_SHE_YANG4_FUNCTION = TestFunction(
    xin_she_yang4,
    xin_she_yang4_gradient,
    Dict{Symbol, Any}(
        :name => "xin_she_yang4",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Xin-She Yang No. 4 function; Properties based on Jamil & Yang (2013, p. 39); originally proposed by Xin-She Yang.",
        :math => raw"""f(\mathbf{x}) = \left[ \sum_{i=1}^{D} \sin^2(x_i) - e^{-\sum_{i=1}^{D} x_i^2} \right] \cdot e^{-\sum_{i=1}^{D} \sin^2 \sqrt{|x_i|}}""",  # Exakt per [RULE_SOURCE_FORMULA_CONSISTENCY]
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension")); fill(1.0, n) end,  # Float64-Literale [Meta-Typ-Scope-Fehler]
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> -1.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "multimodal", "non-separable", "scalable"],
        :source => "Jamil & Yang (2013, p. 39)",  # Mit Seite [RULE_PROPERTIES_SOURCE]
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang4 requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
