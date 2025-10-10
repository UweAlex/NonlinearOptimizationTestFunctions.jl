# src/functions/chungreynolds.jl
# Purpose: Implementation of the Chung Reynolds test function.
# Context: Scalable (n>=1), partially separable, unimodal. Source: Jamil & Yang (2013), validated via al-roomi.org.
# Global minimum: f(x*)=0 at x*=[0,...,0].
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: September 24, 2025.

export CHUNGREYNOLDS_FUNCTION, chungreynolds, chungreynolds_gradient

function chungreynolds(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Chung Reynolds requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    return sum_sq^2
end

function chungreynolds_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Chung Reynolds requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    grad = similar(x)
    @inbounds for i in 1:n
        grad[i] = 4 * sum_sq * x[i]
    end
    return grad
end

const CHUNGREYNOLDS_FUNCTION = TestFunction(
    chungreynolds,
    chungreynolds_gradient,
    Dict(
        :name => "chungreynolds",
        :description => "Chung Reynolds function (continuous, differentiable, partially separable, scalable, unimodal). Source: Jamil & Yang (2013) and Chung & Reynolds (1998). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \left( \sum_{i=1}^n x_i^2 \right)^2 """,
        :start => (n::Int) -> (n < 1 && throw(ArgumentError("Start requires n >= 1")); fill(1.0, n)),
        :min_position => (n::Int) -> (n < 1 && throw(ArgumentError("Min position requires n >= 1")); zeros(n)),
        :min_value => (n::Int) -> (n < 1 && throw(ArgumentError("Min value requires n >= 1")); 0.0),
        :properties => ["bounded", "continuous", "differentiable", "partially separable", "scalable", "unimodal"],
        :default_n => 2,
        :lb => (n::Int) -> (n < 1 && throw(ArgumentError("LB requires n >= 1")); fill(-100.0, n)),
        :ub => (n::Int) -> (n < 1 && throw(ArgumentError("UB requires n >= 1")); fill(100.0, n)),
    )
)
