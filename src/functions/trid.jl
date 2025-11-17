# src/functions/trid.jl
# Purpose: Implementation of the Trid test function.
# Global minimum: f(x*)= -n*(n+4)*(n-1)/6 at x*=[i*(n+1 - i) for i=1:n].
# Bounds: -n^2 ≤ x_i ≤ n^2.

export TRID_FUNCTION, trid, trid_gradient

function trid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("trid requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    sum1 = zero(T)
    sum2 = zero(T)
    @inbounds for i in 1:n
        sum1 += (x[i] - 1.0)^2
    end
    @inbounds for i in 2:n
        sum2 += x[i] * x[i-1]
    end
    sum1 - sum2
end

function trid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("trid requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds grad[1] = 2.0 * (x[1] - 1.0) - x[2]
    @inbounds for i in 2:n-1
        grad[i] = 2.0 * (x[i] - 1.0) - x[i-1] - x[i+1]
    end
    if n >= 2
        @inbounds grad[n] = 2.0 * (x[n] - 1.0) - x[n-1]
    end
    grad
end

const TRID_FUNCTION = TestFunction(
    trid,
    trid_gradient,
    Dict{Symbol, Any}(
        :name => "trid",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Trid function. Properties based on Jamil & Yang (2013, p. 35); originally from Dixon & Szegö (1978).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n (x_i - 1)^2 - \sum_{i=2}^n x_i x_{i-1}.""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); [i * (n + 1 - i) for i in 1:n] end,
        :min_value => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); -n * (n + 4) * (n - 1) / 6.0 end,
        :default_n => 2,  # Kleinste n >1; hier 2 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["bounded", "continuous", "convex", "differentiable", "non-separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); fill(-n^2, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); fill(n^2, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "trid" == basename(@__FILE__)[1:end-3] "trid: Dateiname mismatch!"