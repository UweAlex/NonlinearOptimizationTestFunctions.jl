# src/functions/shubert.jl
# Purpose: Implements the Shubert test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 19. Juli 2025

export SHUBERT_FUNCTION, shubert, shubert_gradient

using LinearAlgebra

# Computes the Shubert function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# Throws `ArgumentError` if the input vector is not 2-dimensional.
function shubert(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    sum1 = sum(i * cos((i + 1) * x1 + i) for i in 1:5)
    sum2 = sum(i * cos((i + 1) * x2 + i) for i in 1:5)
    return sum1 * sum2 # Standarddefinition ohne negatives Vorzeichen
end #function

# Computes the gradient of the Shubert function. Returns a vector of length 2.
#
# Throws `ArgumentError` if the input vector is not 2-dimensional.
function shubert_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    sum1 = sum(i * cos((i + 1) * x1 + i) for i in 1:5)
    sum2 = sum(i * cos((i + 1) * x2 + i) for i in 1:5)
    dsum1 = sum(-i * (i + 1) * sin((i + 1) * x1 + i) for i in 1:5)
    dsum2 = sum(-i * (i + 1) * sin((i + 1) * x2 + i) for i in 1:5)
    return [dsum1 * sum2, sum1 * dsum2] # Gradient angepasst
end #function

const SHUBERT_FUNCTION = TestFunction(
    shubert,
    shubert_gradient,
    Dict(
        :name => "shubert",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [0.0, 0.0]
        end, #function
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [-1.425128428319761, -0.8003211004719731]
        end, #function
        :min_value => () -> -186.73090883102384,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded","continuous"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [-10.0, -10.0]
        end, #function
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [10.0, 10.0]
        end, #function
        :in_molga_smutnicki_2005 => true,
        :description => "Shubert function: Multimodal, non-convex, non-separable, differentiable, bounded (n=2 only). Has 18 global minima, including [-1.425128428319761, -0.8003211004719731].",
        :math => "\\left(\\sum_{i=1}^5 i \\cos((i+1)x_1 + i)\\right) \\left(\\sum_{i=1}^5 i \\cos((i+1)x_2 + i)\\right)"
    )
)