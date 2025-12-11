# src/functions/whitley.jl
# Purpose: Implementation of the Whitley test function.
# Global minimum: f(x*)=0.0 at x*=(1.0, ..., 1.0).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export WHITLEY_FUNCTION, whitley, whitley_gradient

function whitley(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("whitley requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec precision set (only for BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    sum_total = zero(T)
    @inbounds for i in 1:n
        for j in 1:n
            y = x[i]^2 - x[j]  # No T() needed [RULE_TYPE_CONVERSION_MINIMAL]
            a = 100 * y^2 + (1 - x[j])^2
            sum_total += a^2 / 4000 - cos(a) + 1
        end
    end
    sum_total
end

function whitley_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("whitley requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec precision set (only for BigFloat) [RULE_HIGH_PREC_SUPPORT]
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for k in 1:n
        sum_k = zero(T)
        # Term when i == k: sum_j dg_{k j} / dx_k (as i=k)
        for j in 1:n
            y_kj = x[k]^2 - x[j]
            a_kj = 100 * y_kj^2 + (1 - x[j])^2
            da_kj_dxk_i = 400 * y_kj * x[k]  # Korrigiert: 400 statt 200
            factor_kj = a_kj / 2000 + sin(a_kj)
            sum_k += da_kj_dxk_i * factor_kj
        end
        # Term when j == k: sum_i dg_{i k} / dx_k (as j=k)
        for i in 1:n
            y_ik = x[i]^2 - x[k]
            a_ik = 100 * y_ik^2 + (1 - x[k])^2
            da_ik_dxk_j = -200 * y_ik - 2 * (1 - x[k])
            factor_ik = a_ik / 2000 + sin(a_ik)
            sum_k += da_ik_dxk_j * factor_ik
        end
        grad[k] = sum_k
    end
    grad
end

const WHITLEY_FUNCTION = TestFunction(
    whitley,
    whitley_gradient,
    Dict{Symbol, Any}(
        :name => "whitley",  # [RULE_NAME_CONSISTENCY]
        :description => "The Whitley function is a multimodal, non-separable test function for global optimization. Properties based on Jamil & Yang (2013, #167); originally from Whitley et al. (1996).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D \sum_{j=1}^D \left[ \frac{\left(100(x_i^2 - x_j)^2 + (1 - x_j)^2\right)^2}{4000} - \cos\left(100(x_i^2 - x_j)^2 + (1 - x_j)^2\right) + 1 \right]""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("whitley requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("whitley requires at least 1 dimension")); fill(1.0, n) end,
        :min_value => (n::Int) -> 0.0,  # Constant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, #167)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("whitley requires at least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("whitley requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validation on load
