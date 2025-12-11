# src/functions/dejongf5modified.jl
# Purpose: Implements the modified De Jong F5 (Shekel's Foxholes) test function for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 13, 2025

using LinearAlgebra
using ForwardDiff

"""
    dejongf5modified(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the modified De Jong F5 (Shekel's Foxholes) function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and 0 for inputs containing `Inf`. Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5modified(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5modified requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(0.0)  # Finite at infinity

    # Parameters for Shekel's Foxholes (m=25, SFU)
    a = [-32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0;
         -32.0 -32.0 -32.0 -32.0 -32.0 -16.0 -16.0 -16.0 -16.0 -16.0 0.0 0.0 0.0 0.0 0.0 16.0 16.0 16.0 16.0 16.0 32.0 32.0 32.0 32.0 32.0]

    sum = zero(T)
    for i in 1:25
        denom = T(i)
        for j in 1:2
            denom += (x[j] - a[j, i])^6
        end
        sum += 1 / denom
    end
    return (T(0.002) + sum)^(-1)  # Negative sign for minimization
end

"""
    dejongf5modified_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the modified De Jong F5 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5modified_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("DeJongF5modified requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return zeros(T, 2)  # Gradient is zero at infinity

    a = [-32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0 -32.0 -16.0 0.0 16.0 32.0;
         -32.0 -32.0 -32.0 -32.0 -32.0 -16.0 -16.0 -16.0 -16.0 -16.0 0.0 0.0 0.0 0.0 0.0 16.0 16.0 16.0 16.0 16.0 32.0 32.0 32.0 32.0 32.0]

    sum = zero(T)
    grad = zeros(T, 2)
    for i in 1:25
        denom = T(i)
        for j in 1:2
            denom += (x[j] - a[j, i])^6
        end
        sum += 1 / denom
        for j in 1:2
            grad[j] += (-6 * (x[j] - a[j, i])^5) / (denom^2)
        end
    end
    base = T(0.002) + sum
    return -grad / (base^2)  # Gradient of negative function
end

const DEJONGF5MODIFIED_FUNCTION = TestFunction(
    dejongf5modified,
    dejongf5modified_gradient,
    Dict(
        :name => "dejongf5modified",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-31.97833, -31.97833],
        :min_value => () -> 0.9980038377944507,  # Corrected value
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "finite_at_inf", "continuous"]),
        :lb => () -> [-65.536, -65.536],
        :ub => () -> [65.536, 65.536],
        :in_molga_smutnicki_2005 => true,
        :description => "Modified De Jong F5 (Shekel's Foxholes): Multimodal, non-convex, non-separable, differentiable, bounded, finite at infinity, continuous. Minimum: 0.9980038377944507 at x ≈ [-31.97833, -31.97833]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.",
        :math => "-\\left( \\frac{1}{500} + \\sum_{i=1}^{25} \\frac{1}{i + (x_1 - a_{1i})^6 + (x_2 - a_{2i})^6} \\right)^{-1}"
    )
)

export DEJONGF5MODIFIED_FUNCTION, dejongf5modified, dejongf5modified_gradient