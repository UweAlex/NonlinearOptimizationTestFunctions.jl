# src/functions/griewank.jl
# Purpose: Implements the Griewank test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: September 12, 2025

using LinearAlgebra
using ForwardDiff

# Computes the Griewank function value at point `x`. Requires at least 1 dimension.
#
# The function is defined as:
# f(x) = \sum_{i=1}^n x_i^2 / 4000 - \prod_{i=1}^n \cos(x_i / \sqrt{i}) + 1
#
# Arguments:
# - `x`: Input vector of length n >= 1.
#
# Returns:
# - Function value as type `T`.
# - `NaN` if any input is `NaN`.
# - `Inf` if any input is `Inf`.
#
# Throws:
# - `ArgumentError` if the input vector is empty.
#
# Example:
# julia> griewank([0.0, 0.0])
# 0.0
function griewank(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum_term = sum(x[i]^2 / T(4000) for i in 1:n)
    prod_term = prod(cos(x[i] / sqrt(T(i))) for i in 1:n)
    return sum_term - prod_term + T(1)
end #function

# Computes the gradient of the Griewank function at point `x`. Requires at least 1 dimension.
#
# Arguments:
# - `x`: Input vector of length n >= 1.
#
# Returns:
# - Gradient vector of length n as type `Vector{T}`.
# - `fill(NaN, n)` if any input is `NaN`.
# - `fill(Inf, n)` if any input is `Inf`.
#
# Throws:
# - `ArgumentError` if the input vector is empty.
function griewank_gradient(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    for i in 1:n
        prod_term = prod(j == i ? 1 : cos(x[j] / sqrt(T(j))) for j in 1:n)
        grad[i] = T(2) * x[i] / T(4000) + sin(x[i] / sqrt(T(i))) * prod_term / sqrt(T(i))
    end #for
    return grad
end #function

const GRIEWANK_FUNCTION = TestFunction(
    griewank,
    griewank_gradient,
    Dict(
        :name => "griewank",
        :start => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["differentiable", "multimodal", "non-convex", "non-separable", "scalable", "continuous", "bounded"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(-600.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(600.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :dimension => -1,
        :description => raw"Griewank function: A scalable, multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with a global minimum at (0, ..., 0) with value 0.0. References: Jamil & Yang (2013), al-roomi.org.",
        :math => raw"f(x) = \sum_{i=1}^n \frac{x_i^2}{4000} - \prod_{i=1}^n \cos\left(\frac{x_i}{\sqrt{i}}\right) + 1"
    )
)
