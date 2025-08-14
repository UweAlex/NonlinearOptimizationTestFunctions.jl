# src/functions/dejongf5.jl
# Purpose: Implements the De Jong F5 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 14 August 2025

export DEJONGF5_FUNCTION, dejongf5, dejongf5_gradient

using LinearAlgebra
using ForwardDiff

"""
    dejongf5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the De Jong F5 function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and a finite value for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    S = 0.0
    for i in -2:2
        for j in -2:2
            den = 5 * (i + 2) + j + 3 + (x[1] - 16 * j)^6 + (x[2] - 16 * i)^6
            S += 1.0 / den
        end
    end
    return 1.0 / (0.002 + S)
end

"""
    dejongf5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the De Jong F5 function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dejongf5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return zeros(T, n)  # Gradient is zero at Inf due to function structure
    S = 0.0
    dS_dx = zeros(T, 2)
    for i in -2:2
        for j in -2:2
            den = 5 * (i + 2) + j + 3 + (x[1] - 16 * j)^6 + (x[2] - 16 * i)^6
            S += 1.0 / den
            d_den_dx1 = 6 * (x[1] - 16 * j)^5
            d_den_dx2 = 6 * (x[2] - 16 * i)^5
            dS_dx[1] += -1.0 / den^2 * d_den_dx1
            dS_dx[2] += -1.0 / den^2 * d_den_dx2
        end
    end
    base = 0.002 + S
    return -1.0 / base^2 * dS_dx
end

const DEJONGF5_FUNCTION = TestFunction(
    dejongf5,
    dejongf5_gradient,
    Dict(
        :name => "De Jong F5",
        :start => (n::Int) -> begin
            n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int) -> begin
            n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
            [-32.0, -32.0]
        end,
        :min_value => 0.9980038388186492,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "finite_at_inf"]),
        :lb => (n::Int) -> begin
            n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
            [-65.536, -65.536]
        end,
        :ub => (n::Int) -> begin
            n == 2 || throw(ArgumentError("De Jong F5 requires exactly 2 dimensions"))
            [65.536, 65.536]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "De Jong F5 function: Multimodal, finite at infinity, non-convex, non-separable, differentiable function defined for n=2, with regularly distributed local minima.",
        :math => "f(x_1, x_2) = \\left(0.002 + \\sum_{i=-2}^{2} \\sum_{j=-2}^{2} \\frac{1}{5(i+2) + j + 3 + (x_1 - 16j)^6 + (x_2 - 16i)^6}\\right)^{-1}"
    )
)