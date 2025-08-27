# src/functions/levy.jl
# Purpose: Implements the standard Levy function (Wikipedia, Al-Roomi) with its gradient.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 27, 2025

using LinearAlgebra
using ForwardDiff

"""
    levy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the standard Levy function value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function levy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    w = 1 .+ (x .- 1) / 4
    term1 = sin(π * w[1])^2
    term2 = n > 1 ? sum((w[i] - 1)^2 * (1 + 10 * sin(π * w[i] + 1)^2) for i in 1:n-1) : zero(T)
    term3 = (w[n] - 1)^2 * (1 + sin(2 * π * w[n])^2)  # Correct: 2 * π
    term1 + term2 + term3
end

"""
    levygradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the standard Levy function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function levygradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    w = 1 .+ (x .- 1) / 4
    grad = zeros(T, n)
    dw_dx = 0.25
    grad[1] = 2 * π * sin(π * w[1]) * cos(π * w[1]) * dw_dx
    if n > 1
        grad[1] += 2 * (w[1] - 1) * (1 + 10 * sin(π * w[1] + 1)^2) * dw_dx
    end
    for i in 2:n-1
        grad[i] = 2 * (w[i] - 1) * (1 + 10 * sin(π * w[i] + 1)^2) * dw_dx +
                  10 * π * sin(π * w[i] + 1) * cos(π * w[i] + 1) * (w[i-1] - 1)^2 * dw_dx
    end
    grad[n] = 2 * (w[n] - 1) * (1 + sin(2 * π * w[n])^2) * dw_dx +
              4 * π * sin(2 * π * w[n]) * cos(2 * π * w[n]) * (w[n] - 1) * dw_dx
    if n > 1
        grad[n] += 10 * π * sin(π * w[n] + 1) * cos(π * w[n] + 1) * (w[n-1] - 1)^2 * dw_dx
    end
    grad
end

const LEVYFUNCTION = TestFunction(
    levy,
    levygradient,
    Dict(
        :name => "levy",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_value => 0.0,
        :properties => Set(["differentiable", "non-convex", "scalable", "multimodal", "bounded", "continuous"]),
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (standard) requires at least 1 dimension"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Standard Levy function: Multimodal, differentiable, non-convex, scalable, bounded, continuous. Global minimum at x* = (1, ..., 1), f* = 0. Bounds: [-10, 10]^n. Uses w_i = 1 + (x_i - 1)/4, as per standard literature (e.g., Wikipedia, Al-Roomi, 2015: https://www.al-roomi.org/benchmarks/unconstrained). See levyjamil.jl for the Jamil & Yang (2013) version. The function is also non-separable, but this property is omitted in tests for consistency. Included in [Molga & Smutnicki (2005)].",
        :math => "\\sin^2(\\pi w_1) + \\sum_{i=1}^{n-1} (w_i - 1)^2 [1 + 10 \\sin^2(\\pi w_i + 1)] + (w_n - 1)^2 [1 + \\sin^2(2\\pi w_n)], \\quad w_i = 1 + \\frac{x_i - 1}{4}"
    )
)

export LEVYFUNCTION, levy, levygradient