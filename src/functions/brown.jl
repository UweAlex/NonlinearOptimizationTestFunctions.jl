# src/functions/brown.jl
# Purpose: Implements the Brown test function with its gradient for nonlinear optimization.
# Last modified: September 03, 2025

using LinearAlgebra
using ForwardDiff

function brown(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = zero(T)
    for i in 1:(n-1)
        sum += (x[i]^2)^(x[i+1]^2 + 1) + (x[i+1]^2)^(x[i]^2 + 1)
    end
    return sum
end

function brown_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    eps = T(1e-8)  # Increased for numerical stability
    # k = 1
    grad[1] = 2 * x[1] * (x[2]^2 + 1) * (x[1]^2)^(x[2]^2) + 2 * x[1] * (x[2]^2)^(x[1]^2 + 1) * log(abs(x[2]^2) + eps)
    # k = 2, ..., n-1
    for i in 2:(n-1)
        grad[i] = 2 * x[i] * (x[i+1]^2 + 1) * (x[i]^2)^(x[i+1]^2) +
                  2 * x[i] * (x[i+1]^2)^(x[i]^2 + 1) * log(abs(x[i+1]^2) + eps) +
                  2 * x[i] * (x[i-1]^2 + 1) * (x[i]^2)^(x[i-1]^2) +
                  2 * x[i] * (x[i-1]^2)^(x[i]^2 + 1) * log(abs(x[i-1]^2) + eps)
    end
    # k = n
    grad[n] = 2 * x[n] * (x[n-1]^2 + 1) * (x[n]^2)^(x[n-1]^2) +
              2 * x[n] * (x[n-1]^2)^(x[n]^2 + 1) * log(abs(x[n-1]^2) + eps)
    return grad
end

const BROWN_FUNCTION = TestFunction(
    brown,
    brown_gradient,
    Dict(
        :name => "brown",
        :start => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
            zeros(n)
        end,
        :min_value => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
            0.0
        end,
        :properties => Set(["unimodal", "non-separable", "differentiable", "scalable", "continuous", "bounded"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
            fill(-1.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Brown requires at least 2 dimensions"))
            fill(4.0, n)
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Brown function: Unimodal, non-separable, differentiable, scalable, continuous, bounded. Highly sensitive to changes in variables due to exponential terms.",
        :math => "\\sum_{i=1}^{n-1} \\left[ (x_i^2)^{(x_{i+1}^2 + 1)} + (x_{i+1}^2)^{(x_i^2 + 1)} \\right]"
    )
)

export BROWN_FUNCTION, brown, brown_gradient
