# src/functions/xin_she_yang1.jl
# Purpose: Implementation of the Xin-She Yang Function 1 test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n) (deterministic).
# Bounds: -5.0 ≤ x_i ≤ 5.0.

export XIN_SHE_YANG1_FUNCTION, xin_she_yang1, xin_she_yang1_gradient

function xin_she_yang1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # [RULE_HIGH_PREC_SUPPORT]
    end
    
    # Noise: Random ε_i ~ U[0,1]; for Dual: fixed 0.5 (deterministic for AD)
    if T <: ForwardDiff.Dual
        ε = fill(T(0.5), n)  # Fixed mean for differentiability
    else
        ε = rand(T, n)  # Stochastic for f
    end
    
    sum_ = zero(T)
    @inbounds for i in 1:n
        abs_xi = abs(x[i])
        sum_ += ε[i] * abs_xi ^ i
    end
    sum_
end

function xin_she_yang1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    # Deterministic ε=0.5 for grad (per noise handling: grad deterministic)
    ε = fill(T(0.5), n)
    @inbounds for i in 1:n
        xi = x[i]
        abs_xi = abs(xi)
        if abs_xi > 0  # Avoid 0^0; at 0, grad_i=0
            pow = abs_xi ^ (i - 1)
            grad[i] = ε[i] * i * sign(xi) * pow
        end  # At xi=0, grad_i=0
    end
    grad
end

const XIN_SHE_YANG1_FUNCTION = TestFunction(
    xin_she_yang1,
    xin_she_yang1_gradient,
    Dict{Symbol, Any}(
        :name => "xin_she_yang1",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Xin-She Yang Function 1; Properties based on Jamil & Yang (2013, Section 3); stochastic with ε_i ~ U[0,1] per evaluation (has_noise, f noisy but min=0 deterministic at zeros); separable (independent terms); partially differentiable due to abs at 0.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D \epsilon_i |x_i|^i, \quad \epsilon_i \sim U(0,1).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension")); randn(n) .* 5 end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Deterministic [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 [RULE_DEFAULT_N]
        :properties => ["bounded", "has_noise", "scalable", "separable", "unimodal", "partially differentiable"],
        :source => "Jamil & Yang (2013, Section 3)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension")); fill(-5.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang1 requires at least 1 dimension")); fill(5.0, n) end,
    )
)

# Optional: Validierung beim Laden
