# src/functions/sargan.jl
# Purpose: Implementation of the Sargan test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-dependent).
# Bounds: -100 ≤ x_i ≤ 100.

export SARGAN_FUNCTION, sargan, sargan_gradient

function sargan(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sumx = zero(T)
    sum_pow2 = zero(T)
    @inbounds for i in 1:n
        sumx += x[i]
        sum_pow2 += x[i]^2
    end
    0.6 * sum_pow2 + 0.4 * sumx^2
end

function sargan_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    sumx = zero(T)
    @inbounds for i in 1:n
        sumx += x[i]
    end
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 1.2 * x[i] + 0.8 * sumx
    end
    grad
end

const SARGAN_FUNCTION = TestFunction(
    sargan,
    sargan_gradient,
    Dict(
        :name => "sargan",
        :description => "The Sargan function. Properties based on Jamil & Yang (2013, p. 27); originally from Dixon & Szegö (1978).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 + 0.4 \sum_{j \neq i} x_i x_j).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Constant value (ignores n)
        :default_n => 2,  # Smallest n >1 for general scalability
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 27)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)