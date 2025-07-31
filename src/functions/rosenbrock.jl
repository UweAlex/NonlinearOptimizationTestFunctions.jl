# src/functions/rosenbrock.jl
# Purpose: Implements the Rosenbrock test function for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, follows guidelines from Anleitung_neue_Testfunktion.txt.
# Last modified: 19. Juli 2025

export ROSENBROCK_FUNCTION, rosenbrock, rosenbrock_gradient

using LinearAlgebra

"""
    rosenbrock(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Rosenbrock function value at point `x`. Requires at least 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function rosenbrock(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Rosenbrock requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum(100 * (x[i+1] - x[i]^2)^2 + (1 - x[i])^2 for i in 1:length(x)-1)
end

"""
    rosenbrock_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Rosenbrock function. Returns a vector of length n.
"""
function rosenbrock_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Rosenbrock requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    g = zeros(T, n)
    for i in 1:n-1
        g[i] += -400 * x[i] * (x[i+1] - x[i]^2) - 2 * (1 - x[i])
        g[i+1] += 200 * (x[i+1] - x[i]^2)
    end
    g
end

const ROSENBROCK_FUNCTION = TestFunction(
    rosenbrock,
    rosenbrock_gradient,
    Dict(
        :name => "rosenbrock",
        :start => (n::Int=2) -> zeros(n),
        :min_position => (n::Int=2) -> ones(n),
        :min_value => 0.0,
        :properties => Set(["differentiable", "non-convex", "non-separable", "unimodal", "bounded"]),  # Geändert von "multimodal" zu "unimodal"
        :lb => (n::Int=2) -> fill(-5.0, n),
        :ub => (n::Int=2) -> fill(5.0, n),
        :in_molga_smutnicki_2005 => true,
        :description => "Rosenbrock function: non-convex, unimodal, often used as a test for optimization algorithms.",
        :math => "\\sum_{i=1}^{n-1} [100(x_{i+1} - x_i^2)^2 + (1 - x_i)^2]"
    )
)