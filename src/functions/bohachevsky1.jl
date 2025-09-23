# src/functions/bohachevsky1.jl
# Purpose: Implementation of the Bohachevsky 1 test function.
# Context: Scalable (n>=2), from Bohachevsky et al. (1986), continuous, differentiable, separable, multimodal, bounded.
# Global minimum: f(x*)=0 at x*=zeros(n).
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: September 23, 2025.

export BOHACHEVSKY1_FUNCTION, bohachevsky1, bohachevsky1_gradient

function bohachevsky1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 2 && throw(ArgumentError("Bohachevsky 1 requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum_sq = zero(T)
    @inbounds for i in 1:(n-1)
        sum_sq += x[i]^2 + 2 * x[i+1]^2 - 0.3 * cos(3 * π * x[i]) - 0.4 * cos(4 * π * x[i+1]) + 0.7
    end
    return sum_sq
end

function bohachevsky1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 2 && throw(ArgumentError("Bohachevsky 1 requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    @inbounds for i in 1:(n-1)
        sin_term_i = sin(3 * π * x[i])
        sin_term_ip1 = sin(4 * π * x[i+1])
        grad[i] += 2 * x[i] + 0.9 * π * sin_term_i
        grad[i+1] += 4 * x[i+1] + 1.6 * π * sin_term_ip1
    end
    return grad
end

const BOHACHEVSKY1_FUNCTION = TestFunction(
    bohachevsky1,
    bohachevsky1_gradient,
    Dict(
        :name => "bohachevsky1",
        :description => "Bohachevsky Function 1 (Bohachevsky et al., 1986): A scalable, separable, multimodal test function for nonlinear optimization.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[ x_i^2 + 2 x_{i+1}^2 - 0.3 \cos(3 \pi x_i) - 0.4 \cos(4 \pi x_{i+1}) + 0.7 \right].""",
        :start => (n::Int) -> (n < 2 && throw(ArgumentError("...")); fill(1.0, n)),
        :min_position => (n::Int) -> (n < 2 && throw(ArgumentError("...")); zeros(n)),
        :min_value => (n::Int) -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "scalable", "separable"],
        :lb => (n::Int) -> (n < 2 && throw(ArgumentError("...")); fill(-100.0, n)),
        :ub => (n::Int) -> (n < 2 && throw(ArgumentError("...")); fill(100.0, n)),
    )
)