# src/functions/shubert.jl
# Purpose: Implements the Shubert test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 19. Juli 2025

export SHUBERT_FUNCTION, shubert, shubert_gradient

using LinearAlgebra

function shubert(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    sum1 = sum(i * cos((i + 1) * x1 + i) for i in 1:5)
    sum2 = sum(i * cos((i + 1) * x2 + i) for i in 1:5)
    return sum1 * sum2 # Standarddefinition ohne negatives Vorzeichen
end

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
end

const SHUBERT_FUNCTION = TestFunction(
    shubert,
    shubert_gradient,
    Dict(
        :name => "shubert",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [0.0, 0.0]
        end,
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [-1.4251286, -0.800321]
        end,
        :min_value => -186.7309, # Standardwert aus der Literatur
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [-10.0, -10.0]
        end,
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Shubert requires exactly 2 dimensions"))
            [10.0, 10.0]
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Shubert function: Multimodal, non-convex, non-separable, differentiable, bounded (n=2 only). Has 18 global minima.",
        :math => "\\left(\\sum_{i=1}^5 i \\cos((i+1)x_1 + i)\\right) \\left(\\sum_{i=1}^5 i \\cos((i+1)x_2 + i)\\right)"
    )
)