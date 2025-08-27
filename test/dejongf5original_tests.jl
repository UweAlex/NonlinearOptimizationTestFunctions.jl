# src/functions/dejongf5original.jl
# Purpose: Implements the original De Jong F5 test function (Shekel function variant) for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 26, 2025

using LinearAlgebra
using ForwardDiff

"""
    dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the original De Jong F5 function (Shekel variant) value at point `x`. Requires exactly 2 dimensions.
Returns `Inf` for inputs containing `Inf`, `NaN` for inputs containing `NaN`. Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5original(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5original requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)  # Return Inf for Inf inputs

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
    any(isinf.(x)) && return fill(T(Inf), 2)  # Return [Inf, Inf] for Inf inputs

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
        :min_value => -500.01800976967303,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"]),
        :lb => () -> [-65.536, -65.536],
        :ub => () -> [65.536, 65.536],
        :in_molga_smutnicki_2005 => true,
        :description => "De Jong F5 (Shekel variant): Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: -500.018 at [-32, -32]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.",
        :math => "-\\sum_{i=1}^{25} \\frac{1}{\\sum_{j=1}^2 (x_j - a_{ij})^2 + c_i}"
    )
)

export DEJONGF5ORIGINAL_FUNCTION, dejongf5original, dejongf5original_gradient