# src/functions/dejongf4.jl
# Purpose: Implements the De Jong F4 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 26 August 2025

using LinearAlgebra
using ForwardDiff
using Random

# Computes the De Jong F4 function value at point `x`.
function dejongf4(x::AbstractVector{T}; noise::Float64=0.0) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = zero(T)
    for i in 1:n
        sum += i * x[i]^4
    end
    return sum + noise * randn(T)
end #function

# Computes the gradient of the De Jong F4 function at point `x`.
function dejongf4_gradient(x::AbstractVector{T}; noise::Float64=0.0) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    for i in 1:n
        grad[i] = 4 * i * x[i]^3
    end
    return grad  # Rauschen wird im Gradienten ignoriert, da nicht differenzierbar
end #function

const DEJONGF4_FUNCTION = TestFunction(
    dejongf4,
    dejongf4_gradient,
    Dict(
        :name => "dejongf4",
        :start => (n::Int) -> begin
            zeros(Float64, n)
        end, #function
        :min_position => (n::Int) -> begin
            zeros(Float64, n)
        end, #function
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["unimodal", "convex", "separable", "partially differentiable", "scalable", "continuous", "bounded", "has_noise"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            fill(-1.28, n)
        end, #function
        :ub => (n::Int) -> begin
            fill(1.28, n)
        end, #function
        :in_molga_smutnicki_2005 => true,
        :description => "De Jong F4 function: Unimodal, convex, separable, partially differentiable due to Gaussian noise, scalable to any dimension n, with global minimum at x = [0, ..., 0], f* ≈ 0 (depending on noise). Bounds are [-1.28, 1.28] per dimension.",
        :math => "\\sum_{i=1}^n i x_i^4 + \\text{Gaussian noise}"
    )
)

export DEJONGF4_FUNCTION, dejongf4, dejongf4_gradient
