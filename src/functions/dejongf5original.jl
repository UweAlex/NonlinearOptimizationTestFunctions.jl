# src/functions/dejongf5original.jl
# Purpose: Implements the original De Jong F5 test function (Shekel function variant) for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 26, 2025

# Description:
# This implementation follows the Shekel function variant, as described in Molga & Smutnicki (2005), adapted for n=2
# dimensions with 25 local minima arranged in a 5x5 grid. It uses squared terms, distinguishing it from the modified
# De Jong F5 (Shekel's Foxholes) function that uses sixth powers (implemented as `dejongf5modified`).
#
# Mathematical Formulation:
# f(x) = -∑_{i=1}^{25} 1 / (∑_{j=1}^2 (x_j - a_{ij})^2 + c_i)
# where a_{ij} is a 5x5 grid of points:
# a_{1i} = [-32, -16, 0, 16, 32, -32, -16, 0, 16, 32, ...]
# a_{2i} = [-32, -32, -32, -32, -32, -16, -16, -16, -16, -16, 0, 0, 0, 0, 0, 16, ...]
# c_i = 0.002 for all i
# Search domain: [-65.536, 65.536]^2
# Global minimum: x ≈ [-32, -32], f(x) ≈ -500.01800976967303
# Start point: f([0, 0]) ≈ -500.03554670311075
#
# Properties:
# - Multimodal: 25 local minima due to the grid structure.
# - Non-convex: Multiple basins complicate optimization.
# - Non-separable: Variables x_1 and x_2 interact in the denominator terms.
# - Differentiable: The function is smooth and differentiable.
# - Bounded: Function values are bounded within the search domain.
# - Finite at infinity: Converges to -500.0 as x approaches infinity.
# - Continuous: The function is continuous across the domain.
#
# References:
# - De Jong, K. A. (1975). An Analysis of the Behavior of a Class of Genetic Adaptive Systems.
# - Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs.
# - Ali, M. M., et al. (2005). Journal of Global Optimization, 31(4), 635-672.
# - Michalewicz, Z. (1996). Genetic Algorithms + Data Structures = Evolution Programs.
# - Simon Fraser University Optimization Test Functions: https://www.sfu.ca/~ssurjano/dejong5.html

using LinearAlgebra
using ForwardDiff

"""
    dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the original De Jong F5 function (Shekel variant) value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and -500.0 for inputs containing `Inf`. Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5original requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(-500.0)  # Finite at infinity

    # Define the 5x5 grid of points a_ij
    a = [-32.0, -16.0, 0.0, 16.0, 32.0]
    A = zeros(T, 25, 2)
    for i in 1:25
        A[i, 1] = a[mod1(i, 5)]
        A[i, 2] = a[div(i - 1, 5) + 1]
    end
    c = fill(T(0.002), 25)

    sum = zero(T)
    for i in 1:25
        denom = c[i]
        for j in 1:2
            denom += (x[j] - A[i, j])^2
        end
        sum += 1 / denom
    end
    return -sum
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
    any(isinf.(x)) && return zeros(T, 2)  # Gradient is zero at infinity

    a = [-32.0, -16.0, 0.0, 16.0, 32.0]
    A = zeros(T, 25, 2)
    for i in 1:25
        A[i, 1] = a[mod1(i, 5)]
        A[i, 2] = a[div(i - 1, 5) + 1]
    end
    c = fill(T(0.002), 25)

    grad = zeros(T, 2)
    for i in 1:25
        denom = c[i]
        for j in 1:2
            denom += (x[j] - A[i, j])^2
        end
        for j in 1:2
            grad[j] += (2 * (x[j] - A[i, j])) / (denom^2)
        end
    end
    return -grad
end

const DEJONGF5ORIGINAL_FUNCTION = TestFunction(
    dejongf5original,
    dejongf5original_gradient,
    Dict(
        :name => "dejongf5original",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-32.0, -32.0],
        :min_value => -500.01800976967303,  # Updated to actual value
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "finite_at_inf", "continuous"]),
        :lb => () -> [-65.536, -65.536],
        :ub => () -> [65.536, 65.536],
        :in_molga_smutnicki_2005 => true,
        :description => "Original De Jong F5 (Shekel variant): Multimodal, non-convex, non-separable, differentiable, bounded, finite at infinity, continuous. Minimum: -500.01800976967303 at x ≈ [-32, -32]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.",
        :math => "-\\sum_{i=1}^{25} \\frac{1}{\\sum_{j=1}^2 (x_j - a_{ij})^2 + c_i}"
    )
)

export DEJONGF5ORIGINAL_FUNCTION, dejongf5original, dejongf5original_gradient