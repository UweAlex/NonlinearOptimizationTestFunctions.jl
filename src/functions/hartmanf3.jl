# src/functions/hartmanf3.jl
# Purpose: Implements the Hartmann test function (n=3) with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 01 August 2025

export HARTMANF3_FUNCTION, hartmanf3, hartmanf3_gradient

using LinearAlgebra
using ForwardDiff

"""
    hartmanf3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Hartmann function value at point `x`. Requires exactly 3 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function hartmanf3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    alpha = T[1.0, 1.2, 3.0, 3.2]
    A = T[3.0 10.0 30.0; 0.1 10.0 35.0; 3.0 10.0 30.0; 0.1 10.0 35.0]
    P = T[0.3689 0.1170 0.2673; 0.4699 0.4387 0.7470; 0.1091 0.8732 0.5547; 0.03815 0.5743 0.8828]
    
    value = zero(T)
    for i in 1:4
        inner_sum = zero(T)
        for j in 1:3
            inner_sum += A[i, j] * (x[j] - P[i, j])^2
        end
        value += alpha[i] * exp(-inner_sum)
    end
    return -value
end

"""
    hartmanf3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Hartmann function. Returns a vector of length 3.
"""
function hartmanf3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)

    alpha = T[1.0, 1.2, 3.0, 3.2]
    A = T[3.0 10.0 30.0; 0.1 10.0 35.0; 3.0 10.0 30.0; 0.1 10.0 35.0]
    P = T[0.3689 0.1170 0.2673; 0.4699 0.4387 0.7470; 0.1091 0.8732 0.5547; 0.03815 0.5743 0.8828]
    
    grad = zeros(T, 3)
    for i in 1:4
        inner_sum = zero(T)
        for j in 1:3
            inner_sum += A[i, j] * (x[j] - P[i, j])^2
        end
        exp_term = exp(-inner_sum)
        for j in 1:3
            grad[j] += alpha[i] * exp_term * 2.0 * A[i, j] * (x[j] - P[i, j])
        end
    end
    return grad  # Removed the incorrect negation
end

const HARTMANF3_FUNCTION = TestFunction(
    hartmanf3,
    hartmanf3_gradient,
    Dict(
        :name => "hartmanf3",
        :start => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            [0.5, 0.5, 0.5]
        end,
     :min_position => (n::Int=3) -> begin
    n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
    [0.114614339099637, 0.5556488499706311, 0.8525469535196916]
end,
        :min_value => -3.86278214782076,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable","bounded","continuous"]),
        :lb => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            fill(0.0, 3)
        end,
        :ub => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            fill(1.0, 3)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Hartmann function: Multimodal, non-convex, non-separable, differentiable, defined for n=3 only, with a global minimum at [0.114614339099637, 0.5556488499706311, 0.8525469535196916].",
        :math => "-\\sum_{i=1}^4 \\alpha_i \\exp\\left(-\\sum_{j=1}^3 A_{ij} (x_j - P_{ij})^2\\right), \\quad \\alpha=[1,1.2,3,3.2], \\quad A=\\begin{bmatrix}3 & 10 & 30 \\\\ 0.1 & 10 & 35 \\\\ 3 & 10 & 30 \\\\ 0.1 & 10 & 35\\end{bmatrix}, \\quad P=\\begin{bmatrix}0.3689 & 0.1170 & 0.2673 \\\\ 0.4699 & 0.4387 & 0.7470 \\\\ 0.1091 & 0.8732 & 0.5547 \\\\ 0.03815 & 0.5743 & 0.8828\\end{bmatrix}"
    )
)