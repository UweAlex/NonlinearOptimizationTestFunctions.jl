# src/functions/step.jl
# Purpose: Implements the De Jong F3 (Step) test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 09 August 2025

export STEP_FUNCTION, step, step_gradient

using LinearAlgebra
using ForwardDiff

# Computes the De Jong F3 (Step) function value at point `x`. Scalable to any dimension `n ≥ 1`.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
function step(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    isempty(x) && throw(ArgumentError("Step function requires at least one dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sum(floor.(x .+ 0.5) .^ 2)
end #function

# Computes the gradient of the De Jong F3 (Step) function. Returns a zero vector, as the function is not differentiable.
function step_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    isempty(x) && throw(ArgumentError("Step function requires at least one dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    return zeros(T, length(x))  # Gradient is zero everywhere except at discontinuities
end #function

const STEP_FUNCTION = TestFunction(
    step,
    step_gradient,
    Dict(
        :name => "step",
        :start => (n::Int) -> begin
            n ≥ 1 || throw(ArgumentError("Step function requires at least one dimension"))
            fill(0.0, n)
        end,
        :min_position => (n::Int) -> begin
            n ≥ 1 || throw(ArgumentError("Step function requires at least one dimension"))
            fill(0.0, n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["unimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"]),
        :lb => (n::Int) -> begin
            n ≥ 1 || throw(ArgumentError("Step function requires at least one dimension"))
            fill(-5.12, n)
        end,
        :ub => (n::Int) -> begin
            n ≥ 1 || throw(ArgumentError("Step function requires at least one dimension"))
            fill(5.12, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "De Jong F3 (Step) function: Unimodal, non-differentiable, separable, scalable function for testing optimization algorithms on discontinuous problems.",
        :math => "\\sum_{i=1}^n \\lfloor x_i + 0.5 \\rfloor^2"
    )
)