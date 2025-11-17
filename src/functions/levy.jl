# src/functions/levy.jl
# Purpose: Implementation of the Levy test function.
# Global minimum: f(x*)=0.0 at x*=[1.0, 1.0, ..., 1.0] (n-dependent position, constant value).
# Bounds: -10 ≤ x_i ≤ 10.

export LEVY_FUNCTION, levy, levy_gradient

function levy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("levy requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    w = 1.0 .+ (x .- 1.0) / 4.0
    term1 = sin(π * w[1])^2
    term2 = zero(T)
    @inbounds for i in 1:n-1
        term2 += (w[i] - 1.0)^2 * (1.0 + 10.0 * sin(π * w[i] + 1.0)^2)
    end
    term3 = (w[n] - 1.0)^2 * (1.0 + sin(2.0 * π * w[n])^2)
    term1 + term2 + term3
end

function levy_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("levy requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    dw = T(0.25)
    w = 1.0 .+ (x .- 1.0) / 4.0
    @inbounds for i in 1:n
        term1 = zero(T)
        if i == 1
            term1 = π * sin(2 * π * w[i])
        end
        term2 = zero(T)
        if i < n
            # sum term for i=1 to n-1
            s = sin(π * w[i] + 1)^2
            ds_dw = 20 * π * sin(π * w[i] + 1) * cos(π * w[i] + 1)
            term2 = 2 * (w[i] - 1) * (1 + 10 * s) + (w[i] - 1)^2 * ds_dw
        else
            # last term
            s = sin(2 * π * w[i])^2
            ds_dw = 4 * π * sin(2 * π * w[i]) * cos(2 * π * w[i])
            term2 = 2 * (w[i] - 1) * (1 + s) + (w[i] - 1)^2 * ds_dw
        end
        grad[i] = (term1 + term2) * dw
    end
    grad
end

const LEVY_FUNCTION = TestFunction(
    levy,
    levy_gradient,
    Dict{Symbol, Any}(
        :name => "levy",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Levy function. Properties based on Jamil & Yang (2013, p. 164); originally from Levy & Montalvo (1977).",
        :math => raw"""f(\mathbf{x}) = \sin^2(\pi w_1) + \sum_{i=1}^{n-1} (w_i - 1)^2 [1 + 10 \sin^2(\pi w_i + 1)] + (w_n - 1)^2 [1 + \sin^2(2\pi w_n)], \quad w_i = 1 + \frac{x_i - 1}{4}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("levy requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("levy requires at least 1 dimension")); fill(1.0, n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1; hier 2 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "scalable", "separable"],
        :source => "Jamil & Yang (2013, p. 164)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("levy requires at least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("levy requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "levy" == basename(@__FILE__)[1:end-3] "levy: Dateiname mismatch!"