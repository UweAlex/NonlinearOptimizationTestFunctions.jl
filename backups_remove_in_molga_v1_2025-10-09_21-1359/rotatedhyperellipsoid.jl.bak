# src/functions/rotatedhyperellipsoid.jl
# Purpose: Implements the Rotated Hyper-Ellipsoid test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 13. August 2025

export ROTATEDHYPERELLIPSOID_FUNCTION, rotatedhyperellipsoid, rotatedhyperellipsoid_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Rotated Hyper-Ellipsoid function value at point `x`.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# Throws `ArgumentError` if the input vector is empty.
function rotatedhyperellipsoid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum_val = zero(T)
    for i in 1:n
        inner_sum = zero(T)
        for j in 1:i
            inner_sum += x[j]
        end
        sum_val += inner_sum^2
    end
    return sum_val
end #function

# Computes the gradient of the Rotated Hyper-Ellipsoid function. Returns a vector of length n.
#
# Throws `ArgumentError` if the input vector is empty.
function rotatedhyperellipsoid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    y = cumsum(x)  # y[i] = sum_{j=1}^i x[j]
    grad = zeros(T, n)
    for k in 1:n
        grad[k] = 2 * sum(y[k:end])
    end
    return grad
end #function

const ROTATEDHYPERELLIPSOID_FUNCTION = TestFunction(
    rotatedhyperellipsoid,
    rotatedhyperellipsoid_gradient,
    Dict(
        :name => "rotatedhyperellipsoid",
        :start => (n::Int) -> begin
            fill(1.0, n)
        end, #function
        :min_position => (n::Int) -> begin
            zeros(Float64, n)
        end, #function
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["unimodal", "convex", "non-separable", "differentiable", "scalable","bounded","continuous"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            fill(-65.536, n)
        end, #function
        :ub => (n::Int) -> begin
            fill(65.536, n)
        end, #function
        :in_molga_smutnicki_2005 => true,
        :description => "Rotated Hyper-Ellipsoid function: Continuous, convex, unimodal, scalable test function for optimization.",
        :math => "\\sum_{i=1}^{n} \\left( \\sum_{j=1}^{i} x_j \\right)^2"
    )
)
