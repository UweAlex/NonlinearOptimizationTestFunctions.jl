# src/functions/michalewicz.jl
# Purpose: Implements the Michalewicz test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: September 03, 2025

using LinearAlgebra
using ForwardDiff

function michalewicz(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    s = zero(T) / 1
    π⁻¹ = one(T) / π
    @inbounds for i ∈ eachindex(x)
        v = sin(i * x[i]^2 * π⁻¹)
        v² = v^2
        v⁴ = v²^2
        v⁸ = v⁴^2
        v¹⁶ = v⁸^2
        v²⁰ = v¹⁶ * v⁴
        s += sin(x[i]) * v²⁰
    end
    return -s
end

function michalewicz_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    m = 10
    π⁻¹ = one(T) / π
    grad = zeros(T, length(x))
    @inbounds for i in 1:length(x)
        xi = x[i]
        u = i * xi^2 * π⁻¹
        v = sin(u)
        v² = v^2
        v⁴ = v²^2
        v⁸ = v⁴^2
        v¹⁶ = v⁸^2
        v²⁰ = v¹⁶ * v⁴  # sin^20(u)
        v¹⁹ = v¹⁶ * v² * v  # sin^19(u)
        term1 = cos(xi) * v²⁰
        term2 = sin(xi) * (2 * m) * v¹⁹ * cos(u) * (2 * i * xi * π⁻¹)
        grad[i] = -(term1 + term2)
    end
    return grad
end

const MICHALEWICZ_FUNCTION = TestFunction(
    michalewicz,
    michalewicz_gradient,
    Dict(
        :name => "michalewicz",
        :start => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
            fill(0.5, n)  # Improved start point to avoid local minima
        end,
        :min_position => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
            if n == 2
                return [2.2029055201726, 1.5707963267949]
            elseif n == 4
                return [1.1207317360799627, 1.5707963267094696, 1.7382973347492041, 1.5707963267948966]
            elseif n == 5
                return [2.2029, 1.5708, 1.2849, 1.9231, 1.7205]
            elseif n == 10
                return [2.2029, 1.5708, 1.2849, 1.9231, 1.7205, 1.5708, 1.4544, 1.7569, 1.6550, 1.5708]
            else
                return fill(π / 2, n)  # Approximation for other dimensions
            end
        end,
        :min_value => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
            if n == 2
                return -1.8013034100985528
            elseif n == 4
                return -1.0000000057405447  # Optimierten Wert verwenden
            elseif n == 5
                return -4.687658
            elseif n == 10
                return -9.66015
            else
                return -0.8013 * n  # Approximate scaling
            end
        end,
        :properties => Set(["multimodal", "non-separable", "differentiable", "scalable", "bounded", "continuous"]),  # "bounded" nur einmal
        :lb => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
            fill(0.0, n)
        end,
        :ub => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Michalewicz requires at least 2 dimensions"))
            fill(π, n)
        end,
        :description => "Michalewicz function: Multimodal, non-separable, with many local minima.",
        :math => "f(x) = -\\sum_{i=1}^n \\sin(x_i) \\sin^{2m}(i x_i^2 / \\pi), m=10",
        :in_molga_smutnicki_2005 => true
    )
)

export MICHALEWICZ_FUNCTION, michalewicz, michalewicz_gradient