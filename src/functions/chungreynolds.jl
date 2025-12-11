# src/functions/chungreynolds.jl
# Purpose: Implementation of the Chung Reynolds test function.
# Context: Scalable (n>=1), partially separable, unimodal. Source: Jamil & Yang (2013), validated via al-roomi.org.
# Global minimum: f(x*)=0 at x*=[0,...,0].
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: October 22, 2025.

export CHUNGREYNOLDS_FUNCTION, chungreynolds, chungreynolds_gradient

using LinearAlgebra, ForwardDiff

"""
    chungreynolds(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Chung Reynolds function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function chungreynolds(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("chungreynolds requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    sum_sq^2
end

"""
    chungreynolds_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Chung Reynolds function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function chungreynolds_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("chungreynolds requires at least 1 dimension"))
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
    grad
end

const CHUNGREYNOLDS_FUNCTION = TestFunction(
    chungreynolds,
    chungreynolds_gradient,
    Dict(
        :name => "chungreynolds",
        :description => "Chung Reynolds function (continuous, differentiable, partially separable, scalable, unimodal). Source: Jamil & Yang (2013) and Chung & Reynolds (1998). Global minimum at the origin.",
        :math => raw"""f(\mathbf{x}) = \left( \sum_{i=1}^n x_i^2 \right)^2 """,
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("chungreynolds start requires n >= 1")); fill(1.0, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("chungreynolds min position requires n >= 1")); zeros(n) end,
        :min_value => (n::Int) -> begin n < 1 && throw(ArgumentError("chungreynolds min value requires n >= 1")); 0.0 end,
        :properties => ["bounded", "continuous", "differentiable", "partially separable", "scalable", "unimodal"],
        :default_n => 2,
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("chungreynolds lb requires n >= 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("chungreynolds ub requires n >= 1")); fill(100.0, n) end,
        :source => "Jamil & Yang (2013, Entry 34)"
    )
)
