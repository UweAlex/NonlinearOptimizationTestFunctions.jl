# src/functions/levy.jl
# Purpose: Implements the Levy test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 02 August 2025

export LEVY_FUNCTION, levy, levy_gradient

using LinearAlgebra
using ForwardDiff

"""
    levy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Levy function value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function levy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    w = 1 .+ (x .- 1) / 4
    sum = sin(π * w[1])^2
    for i in 1:(n-1)
        sum += (w[i] - 1)^2 * (1 + 10 * sin(π * w[i] + 1)^2)
    end
    sum += (w[n] - 1)^2 * (1 + sin(2π * w[n])^2)
    return sum
end

"""
    levy_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Levy function. Returns a vector of length n.
"""
function levy_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    w = 1 .+ (x .- 1) / 4
    grad = zeros(T, n)
    # Gradient for x_1
    grad[1] = (2 * sin(π * w[1]) * π * cos(π * w[1]) +
               2 * (w[1] - 1) * (1 + 10 * sin(π * w[1] + 1)^2) +
               (w[1] - 1)^2 * 10 * 2 * sin(π * w[1] + 1) * cos(π * w[1] + 1) * π) / 4
    # Gradient for x_2 to x_(n-1)
    for i in 2:(n-1)
        grad[i] = (2 * (w[i] - 1) * (1 + 10 * sin(π * w[i] + 1)^2) +
                   (w[i] - 1)^2 * 10 * 2 * sin(π * w[i] + 1) * cos(π * w[i] + 1) * π +
                   (w[i-1] - 1)^2 * 10 * 2 * sin(π * w[i-1] + 1) * cos(π * w[i-1] + 1) * π) / 4
    end
    # Gradient for x_n
    if n > 1
        grad[n] = (2 * (w[n] - 1) * (1 + sin(2π * w[n])^2) +
                   (w[n] - 1)^2 * 2 * sin(2π * w[n]) * cos(2π * w[n]) * 2π) / 4
    end
    return grad
end

const LEVY_FUNCTION = TestFunction(
    levy,
    levy_gradient,
    Dict(
        :name => "levy",
        :start => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_value => 0.0,
        :properties => Set(["differentiable", "non-convex", "scalable", "multimodal"]),
        :lb => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Levy requires at least 1 dimension"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Levy function: Multimodal, non-convex, scalable function with global minimum at zero.",
        :math => "\\sin^2(\\pi w_1) + \\sum_{i=1}^{n-1} (w_i - 1)^2 (1 + 10 \\sin^2(\\pi w_i + 1)) + (w_n - 1)^2 (1 + \\sin^2(2\\pi w_n)), \\quad w_i = 1 + \\frac{x_i - 1}{4}"
    )
)