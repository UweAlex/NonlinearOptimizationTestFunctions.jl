# src/functions/powellsingular.jl
# Purpose: Implementation of the Powell Singular test function.
# Context: Scalable (n multiple of 4, n >= 4), unimodal with singular Hessian at minimum.
# Global minimum: f(x*)=0 at x*=zeros(n).
# Bounds: -4 ≤ x_i ≤ 5.
# Last modified: September 30, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export POWELSINGULAR_FUNCTION, powellsingular, powellsingular_gradient

function powellsingular(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 4 || n % 4 != 0 && throw(ArgumentError("powellsingular requires dimension n >= 4 and multiple of 4"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_f = zero(T)
    @inbounds for i in 1:(n ÷ 4)
        idx = 4 * (i - 1)
        a = x[idx + 1]
        b = x[idx + 2]
        c = x[idx + 3]
        d = x[idx + 4]
        term1 = a + 10 * b
        term2 = c - d
        term3 = b - 2 * c
        term4 = a - d
        sum_f += term1^2 + 5 * term2^2 + term3^4 + 10 * term4^4
    end
    sum_f
end

function powellsingular_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 4 || n % 4 != 0 && throw(ArgumentError("powellsingular requires dimension n >= 4 and multiple of 4"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:(n ÷ 4)
        idx = 4 * (i - 1)
        a = x[idx + 1]
        b = x[idx + 2]
        c = x[idx + 3]
        d = x[idx + 4]
        term1 = a + 10 * b
        term2 = c - d
        term3 = b - 2 * c
        term4 = a - d
        g_a = 2 * term1 + 40 * term4^3
        g_b = 20 * term1 + 4 * term3^3
        g_c = 10 * term2 - 8 * term3^3
        g_d = -10 * term2 - 40 * term4^3
        grad[idx + 1] = g_a
        grad[idx + 2] = g_b
        grad[idx + 3] = g_c
        grad[idx + 4] = g_d
    end
    grad
end

const POWELSINGULAR_FUNCTION = TestFunction(
    powellsingular,
    powellsingular_gradient,
    Dict(
        :name => "powellsingular",
        :description => "Powell Singular Function, a quartic function with singular Hessian at the global minimum. Scalable in blocks of 4 dimensions. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n/4} \left[ (x_{4i-3} + 10 x_{4i-2})^2 + 5 (x_{4i-1} - x_{4i})^2 + (x_{4i-2} - 2 x_{4i-1})^4 + 10 (x_{4i-3} - x_{4i})^4 \right].""",
        :start => (n::Int) -> begin n < 4 || n % 4 != 0 && throw(ArgumentError("Start requires n >= 4 and multiple of 4")); repeat([3.0, -1.0, 0.0, 1.0], n ÷ 4) end,
        :min_position => (n::Int) -> begin n < 4 || n % 4 != 0 && throw(ArgumentError("Min position requires n >= 4 and multiple of 4")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "scalable", "unimodal"],
        :default_n => 4,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Powell (1962)",
        :lb => (n::Int) -> begin n < 4 || n % 4 != 0 && throw(ArgumentError("LB requires n >= 4 and multiple of 4")); fill(-4.0, n) end,
        :ub => (n::Int) -> begin n < 4 || n % 4 != 0 && throw(ArgumentError("UB requires n >= 4 and multiple of 4")); fill(5.0, n) end,
    )
)
