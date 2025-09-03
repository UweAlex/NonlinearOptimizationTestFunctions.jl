# src/functions/dejongf5original.jl
# Purpose: Implements the original De Jong F5 test function (Shekel variant) for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 02, 2025

# Description:
# This implementation follows the De Jong F5 function as defined in Molga & Smutnicki (2005), designed for n=2
# dimensions with 25 local minima arranged in a 5x5 grid. It uses sixth-power terms and an outer inverse, distinguishing
# it from the modified De Jong F5 (Shekel's Foxholes) function that uses squared terms (implemented as `dejongf5modified`).
#
# Mathematical Formulation:
# f(x_1, x_2) = \left( 0.002 + \sum_{j=1}^{25} \frac{1}{j + (x_1 - a_{1j})^6 + (x_2 - a_{2j})^6} \right)^{-1}
# where a_{ij} is a 5x5 grid of points:
# a_{1j} = [-32, -16, 0, 16, 32, -32, -16, 0, 16, 32, ...]
# a_{2j} = [-32, -32, -32, -32, -32, -16, -16, -16, -16, -16, 0, ...]
# c = 0.002 (constant for all j)
# Search domain: [-65.536, 65.536]^2
# Global minimum: x ≈ [-32, -32], f(x) ≈ 0.998001998667 (approximated)
# Start point: f([0, 0]) ≈ 1.001001001001
#
# Properties:
# - Multimodal: 25 local minima due to the grid structure.
# - Non-convex: Multiple basins complicate optimization.
# - Non-separable: Variables x_1 and x_2 interact in the denominator terms.
# - Differentiable: The function is smooth and differentiable.
# - Bounded: Function values are bounded within the search domain.
# - Continuous: The function is continuous across the domain.
# - Finite at infinity: f(x) → 500 as ||x|| → ∞.
#
# References:
# - Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs.
# - De Jong, K. A. (1975). An Analysis of the Behavior of a Class of Genetic Adaptive Systems.
# - Ali, M. M., et al. (2005). Journal of Global Optimization, 31(4), 635-672.

using LinearAlgebra
using ForwardDiff

"""
    dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the original De Jong F5 function (Shekel variant) value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`. Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5original requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    a = T[-32.0, -16.0, 0.0, 16.0, 32.0]
    A = zeros(T, 25, 2)
    for i in 1:25
        row = div(i - 1, 5)
        col = mod(i - 1, 5)
        A[i, 1] = a[col + 1]
        A[i, 2] = a[row + 1]
    end
    c = T(0.002)
    
    sum = zero(T)
    for j in 1:25
        term = T(j) + (x[1] - A[j,1])^6 + (x[2] - A[j,2])^6
        sum += 1 / term
    end
    return (c + sum)^(-1)
end

"""
    dejongf5original_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the original De Jong F5 function (Shekel variant). Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5original_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5original requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return zeros(T, 2)  # Gradient approaches zero at infinity
    
    a = T[-32.0, -16.0, 0.0, 16.0, 32.0]
    A = zeros(T, 25, 2)
    for i in 1:25
        row = div(i - 1, 5)
        col = mod(i - 1, 5)
        A[i, 1] = a[col + 1]
        A[i, 2] = a[row + 1]
    end
    c = T(0.002)
    
    sum_inv = zero(T)
    for j in 1:25
        term = T(j) + (x[1] - A[j,1])^6 + (x[2] - A[j,2])^6
        sum_inv += 1 / term
    end
    outer_term = (c + sum_inv)^(-2)
    
    grad = zeros(T, 2)
    for j in 1:25
        term = T(j) + (x[1] - A[j,1])^6 + (x[2] - A[j,2])^6
        grad[1] += 6 * (x[1] - A[j,1])^5 / (term^2)
        grad[2] += 6 * (x[2] - A[j,2])^5 / (term^2)
    end
    return outer_term * grad  # Entferne das negative Vorzeichen
end

const DEJONGF5ORIGINAL_FUNCTION = TestFunction(
    dejongf5original,
    dejongf5original_gradient,
    Dict(
        :name => "dejongf5original",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-32.0, -32.0],
        :min_value => 0.998001998667,  # Approximated value at [-32, -32]
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous", "finite_at_inf"]),
        :lb => () -> [-65.536, -65.536],
        :ub => () -> [65.536, 65.536],
        :in_molga_smutnicki_2005 => true,
        :description => "Original De Jong F5 (Shekel variant) as per Molga & Smutnicki (2005): Multimodal, non-convex, non-separable, differentiable, bounded, continuous, finite at infinity. Minimum: ≈0.998001998667 at x ≈ [-32, -32]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.",
        :math => "f(x) = \\left( 0.002 + \\sum_{j=1}^{25} \\frac{1}{j + (x_1 - a_{1j})^6 + (x_2 - a_{2j})^6} \\right)^{-1}"
    )
)

export DEJONGF5ORIGINAL_FUNCTION, dejongf5original, dejongf5original_gradient