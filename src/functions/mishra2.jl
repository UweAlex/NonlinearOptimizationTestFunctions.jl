# src/functions/mishra2.jl
# Purpose: Implementation of the Mishra Function 2 test function.
# Context: Scalable (n>=2), continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*)=2 at x*=fill(1.0, n).
# Bounds: 0 ≤ x_i ≤ 1.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA2_FUNCTION, mishra2, mishra2_gradient

function mishra2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra Function 2 requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    s = zero(T)
    @inbounds for i in 1:n-1
        s += 0.5 * (x[i] + x[i+1])
    end
    g_n = T(n) - s
    (one(T) + g_n)^g_n
end

function mishra2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra Function 2 requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    s = zero(T)
    @inbounds for i in 1:n-1
        s += 0.5 * (x[i] + x[i+1])
    end
    g_n = T(n) - s
    f_val = (one(T) + g_n)^g_n
    grad = zeros(T, n)
    df_dg = f_val * (log(one(T) + g_n) + g_n / (one(T) + g_n))
    @inbounds for j in 1:n
        partial_s_dxj = (j == 1 || j == n) ? T(0.5) : one(T)
        grad[j] = df_dg * (-partial_s_dxj)
    end
    grad
end

const MISHRA2_FUNCTION = TestFunction(
    mishra2,
    mishra2_gradient,
    Dict(
        :name => "mishra2",
        :description => "The Mishra Function 2. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = (1 + g_n)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} \frac{x_i + x_{i+1}}{2} """,
        :start => n -> fill(0.0, n),
        :min_position => n -> fill(1.0, n),
        :min_value => n -> 2.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "scalable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006a)",
        :lb => n -> fill(0.0, n),
        :ub => n -> fill(1.0, n),
    )
)