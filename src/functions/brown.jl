# src/functions/brown.jl
# Purpose: Implements the Brown test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 27. November 2025

export BROWN_FUNCTION, brown, brown_gradient

using LinearAlgebra, ForwardDiff

"""
    brown(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Brown function value at point `x`. Requires at least 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function brown(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("brown requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = zero(T)
    @inbounds for i in 1:(n-1)
        sum += (x[i]^2)^(x[i+1]^2 + 1) + (x[i+1]^2)^(x[i]^2 + 1)
    end
    sum
end

"""
    brown_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Brown function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function brown_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("brown requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    eps = T(1e-8)
    # i=1
    grad[1] = 2 * x[1] * (x[2]^2 + 1) * (x[1]^2)^(x[2]^2) + 2 * x[1] * (x[2]^2)^(x[1]^2 + 1) * log(abs(x[2]^2) + eps)
    # i=2 to n-1
    @inbounds for i in 2:(n-1)
        grad[i] = 2 * x[i] * (x[i+1]^2 + 1) * (x[i]^2)^(x[i+1]^2) +
                  2 * x[i] * (x[i+1]^2)^(x[i]^2 + 1) * log(abs(x[i+1]^2) + eps) +
                  2 * x[i] * (x[i-1]^2 + 1) * (x[i]^2)^(x[i-1]^2) +
                  2 * x[i] * (x[i-1]^2)^(x[i]^2 + 1) * log(abs(x[i-1]^2) + eps)
    end
    # i=n
    if n > 1
        grad[n] = 2 * x[n] * (x[n-1]^2 + 1) * (x[n]^2)^(x[n-1]^2) +
                  2 * x[n] * (x[n-1]^2)^(x[n]^2 + 1) * log(abs(x[n-1]^2) + eps)
    end
    grad
end

const BROWN_FUNCTION = TestFunction(
    brown,
    brown_gradient,
    Dict(
        :name => "brown",
        :start => (n::Int) -> (n < 2 && throw(ArgumentError("brown requires at least 2 dimensions")); fill(1.0, n)),
        :min_position => (n::Int) -> (n < 2 && throw(ArgumentError("brown requires at least 2 dimensions")); zeros(n)),
        :min_value => (n::Int) -> (n < 2 && throw(ArgumentError("brown requires at least 2 dimensions")); 0.0),
        :default_n => 2,
        :properties => ["unimodal", "non-separable", "differentiable", "scalable", "continuous", "bounded"],
        :lb => (n::Int) -> (n < 2 && throw(ArgumentError("brown requires at least 2 dimensions")); fill(-1.0, n)),
        :ub => (n::Int) -> (n < 2 && throw(ArgumentError("brown requires at least 2 dimensions")); fill(4.0, n)),
        :description => "Brown function: Unimodal, non-separable, differentiable, scalable, continuous, bounded. Highly sensitive to changes in variables due to exponential terms. Properties based on [Jamil & Yang (2013, p. 5)]; originally from [Brown (1966)].",
        :math => raw"\sum_{i=1}^{n-1} \left[ (x_i^2)^{(x_{i+1}^2 + 1)} + (x_{i+1}^2)^{(x_i^2 + 1)} \right]",
        :source => "Jamil & Yang (2013, p. 5)"
    )
)