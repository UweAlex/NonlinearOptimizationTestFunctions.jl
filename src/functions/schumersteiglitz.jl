# src/functions/schumersteiglitz.jl
# Purpose: Implements the Schumer-Steiglitz test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 10, 2025

export SCHUMERSTEIGLITZ_FUNCTION, schumersteiglitz, schumersteiglitz_gradient

using LinearAlgebra
using ForwardDiff
using Random  # For randn

# Computes the Schumer-Steiglitz function value at point `x`. Scalable to any dimension n >= 1.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# The Schumer-Steiglitz function is defined as:
# f(x) = ∑_{i=1}^n x_i^4
#
# Reference: Schumer & Steiglitz (1968)
function schumersteiglitz(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    return sum(x .^ 4)
end #function

# Computes the gradient of the Schumer-Steiglitz function. Returns a vector of length n.
#
# Throws `ArgumentError` if the input vector is empty.
function schumersteiglitz_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    return 4 * (x .^ 3)
end #function

const SCHUMERSTEIGLITZ_FUNCTION = TestFunction(
    schumersteiglitz,
    schumersteiglitz_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); randn(n) * 5.0 end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); 0.0 end,
        :default_n => 10,
        :properties => Set(["continuous", "differentiable", "separable", "scalable", "unimodal"]),
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(10.0, n) end,
        :source => "Schumer, M. A. and Steiglitz, K. (1968). Adaptive Step Size Random Search. IEEE Transactions on Automatic Control, 13(3), 270–276.",
        :description => "Schumer-Steiglitz function: A simple separable unimodal function with global minimum at the origin.",
        :math => "f(\\mathbf{x}) = \\sum_{i=1}^{n} x_i^4"
    )
)