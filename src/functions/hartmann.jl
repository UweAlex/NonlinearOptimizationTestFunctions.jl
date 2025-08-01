# src/functions/hartmann.jl
# Purpose: Implements the Hartmann test function (n=3) with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 01 August 2025

export HARTMANN_FUNCTION, hartmann, hartmann_gradient

using LinearAlgebra
using ForwardDiff

"""
    hartmann(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Hartmann function value at point `x`. Requires exactly 3 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function hartmann(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
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
    hartmann_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Hartmann function. Returns a vector of length 3.
"""
function hartmann_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
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

const HARTMANN_FUNCTION = TestFunction(
    hartmann,
    hartmann_gradient,
    Dict(
        :name => "hartmann",
        :start => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            [0.5, 0.5, 0.5]
        end,
        :min_position => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            [0.114614, 0.555649, 0.852547]
        end,
        :min_value => -3.86278214782076,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable"]),
        :lb => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            fill(0.0, 3)
        end,
        :ub => (n::Int=3) -> begin
            n == 3 || throw(ArgumentError("Hartmann requires exactly 3 dimensions"))
            fill(1.0, 3)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Hartmann function: Multimodal, non-convex, non-separable, differentiable, defined for n=3 only, with a global minimum at approximately [0.114614, 0.555649, 0.852547].",
        :math => "-\\sum_{i=1}^4 \\alpha_i \\exp\\left(-\\sum_{j=1}^3 A_{ij} (x_j - P_{ij})^2\\right), \\quad \\alpha=[1,1.2,3,3.2], \\quad A=\\begin{bmatrix}3 & 10 & 30 \\\\ 0.1 & 10 & 35 \\\\ 3 & 10 & 30 \\\\ 0.1 & 10 & 35\\end{bmatrix}, \\quad P=\\begin{bmatrix}0.3689 & 0.1170 & 0.2673 \\\\ 0.4699 & 0.4387 & 0.7470 \\\\ 0.1091 & 0.8732 & 0.5547 \\\\ 0.03815 & 0.5743 & 0.8828\\end{bmatrix}"
    )
)