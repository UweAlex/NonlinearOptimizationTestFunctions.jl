# src/functions/boxbetts.jl
# Purpose: Implements the Box-Betts Quadratic Sum test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 09 September 2025, 10:20 PM CEST
# Source: MVF - Multivariate Test Functions Library in C, Ernesto P. Adorio, Revised January 14, 2005

export BOXBETTS_FUNCTION, boxbetts, boxbetts_gradient

using LinearAlgebra
using ForwardDiff

function boxbetts(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Box-Betts Quadratic Sum requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Funktion: sum_{i=1}^{10} (e^{-0.1i x_1} - e^{-0.1i x_2} - (e^{-0.1i} - e^{-i}) x_3)^2
    g(xi, i) = exp(-0.1 * i * xi[1]) - exp(-0.1 * i * xi[2]) - (exp(-0.1 * i) - exp(-i)) * xi[3]
    return sum(g(x, i)^2 for i in 1:10)
end

function boxbetts_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Box-Betts Quadratic Sum requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)
    
    # Gradient: Ableitung von f(x) = sum_{i=1}^{10} g(x,i)^2
    g(xi, i) = exp(-0.1 * i * xi[1]) - exp(-0.1 * i * xi[2]) - (exp(-0.1 * i) - exp(-i)) * xi[3]
    grad = zeros(T, 3)
    for i in 1:10
        gi = g(x, i)
        coef = -0.1 * i
        grad[1] += 2 * gi * coef * exp(coef * x[1])  # ∂g/∂x₁
        grad[2] += 2 * gi * (-coef) * exp(coef * x[2])  # ∂g/∂x₂
        grad[3] += 2 * gi * (-(exp(-0.1 * i) - exp(-i)))  # ∂g/∂x₃
    end
    return grad
end

const BOXBETTS_FUNCTION = TestFunction(
    boxbetts,
    boxbetts_gradient,
    Dict(
        :name => "boxbetts",
        :start => () -> [1.0, 10.0, 1.0],  # Startpunkt nahe Minimum
        :min_position => () -> [1.0, 10.0, 1.0],
        :min_value => 0.0,
        :properties => Set(["continuous", "differentiable", "multimodal"]),
        :lb => () -> [0.9, 9.0, 0.9],
        :ub => () -> [1.2, 11.2, 1.2],
        :in_molga_smutnicki_2005 => false,
        :description => "Box-Betts Quadratic Sum function: Continuous, differentiable, non-separable, nonscalable, multimodal.",
        :math => "\\sum_{i=1}^{10} \\left( e^{-0.1i x_1} - e^{-0.1i x_2} - (e^{-0.1i} - e^{-i}) x_3 \\right)^2",
        :source => "MVF - Multivariate Test Functions Library in C, Ernesto P. Adorio, Revised January 14, 2005"
    )
)