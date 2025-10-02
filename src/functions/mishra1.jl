# src/functions/mishra1.jl
# Purpose: Implementation of the Mishra Function 1 test function.
# Context: Scalable (n>=2), continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*)=2 at x*=fill(1.0, n).
# Bounds: 0 ≤ x_i ≤ 1.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA1_FUNCTION, mishra1, mishra1_gradient

function mishra1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra Function 1 requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    s = zero(T)
    @inbounds for i in 1:n-1
        s += x[i]
    end
    g_n = T(n) - s
    (one(T) + g_n)^g_n
end

function mishra1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra Function 1 requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    s = zero(T)
    @inbounds for i in 1:n-1
        s += x[i]
    end
    g_n = T(n) - s
    f_val = (one(T) + g_n)^g_n
    grad = zeros(T, n)
    factor = -f_val * (g_n / (one(T) + g_n) + log(one(T) + g_n))
    @inbounds for i in 1:n-1
        grad[i] = factor
    end
    # grad[n] = 0.0 remains
    grad
end

const MISHRA1_FUNCTION = TestFunction(
    mishra1,
    mishra1_gradient,
    Dict(
        :name => "mishra1",
        :description => "The Mishra Function 1. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left(1 + g_n\right)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} x_i """,
        :start => n -> fill(0.0, n),
        :min_position => n -> fill(1.0, n),
        :min_value => n -> 2.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "scalable"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006a)",
        :lb => n -> fill(0.0, n),
        :ub => n -> fill(1.0, n),
    )
)
