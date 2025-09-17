# src/functions/rana.jl
# Purpose: Implements the Rana test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 04 August 2025

export RANA_FUNCTION, rana, rana_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Rana function value at point `x`. Requires exactly 2 dimensions.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
function rana(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    a = x2 + x1 + 1
    b = x2 - x1 + 1
    term1 = sqrt(abs(a))
    term2 = sqrt(abs(b))
    return x1 * sin(term1) * cos(term2) + (x2 + 1) * cos(term1) * sin(term2)
end #function

# Computes the gradient of the Rana function. Returns a vector of length 2.
function rana_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    x1, x2 = x
    a = x2 + x1 + 1
    b = x2 - x1 + 1
    if a == 0 || b == 0
        return fill(T(NaN), 2)
    end

    A = sqrt(abs(a))
    B = sqrt(abs(b))
    sA, cA = sin(A), cos(A)
    sB, cB = sin(B), cos(B)
    sa = sign(a)
    sb = sign(b)

    grad_x1 = cB * sA +
              x1 * (cA * cB * (sa / (2 * A)) + sA * sB * (sb / (2 * B))) +
              (x2 + 1) * (-sA * sB * (sa / (2 * A)) - cA * cB * (sb / (2 * B)))

    grad_x2 = cA * sB +
              x1 * (cA * cB * (sa / (2 * A)) - sA * sB * (sb / (2 * B))) +
              (x2 + 1) * (-sA * sB * (sa / (2 * A)) + cA * cB * (sb / (2 * B)))

    return [grad_x1, grad_x2]
end #function

const RANA_FUNCTION = TestFunction(
    rana,
    rana_gradient,
    Dict(
        :name => "rana",
        :start => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
            [0.0, 0.0]
        end, #function
        :min_position => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
            [-500.0, -499.0733150925747]  # Vorläufig, muss überprüft werden
        end, #function
        :min_value => () -> -498.12463264808594,
        :properties => Set(["multimodal", "partially differentiable", "non-separable","bounded","continuous"]),
        :lb => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
            [-500.0, -500.0]
        end, #function
        :ub => (n::Int=2) -> begin
            n == 2 || throw(ArgumentError("Rana requires exactly 2 dimensions"))
            [500.0, 500.0]
        end, #function
        :in_molga_smutnicki_2005 => true,
        :description => "Rana function: A multimodal, partially differentiable, non-separable function with multiple local minima, defined only for 2 dimensions.",
        :math => "x_1 \\sin(\\sqrt{|x_2 + x_1 + 1|}) \\cos(\\sqrt{|x_2 - x_1 + 1|}) + (x_2 + 1) \\cos(\\sqrt{|x_2 + x_1 + 1|}) \\sin(\\sqrt{|x_2 - x_1 + 1|})"
    )
)