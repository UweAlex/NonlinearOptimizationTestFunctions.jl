# src/functions/griewank.jl
# Purpose: Implements the Griewank test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, used in optimization demos and tests.
# Last modified: 17. Juli 2025

using Base: prod

"""
    griewank(x::AbstractVector)
Computes the Griewank function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function griewank(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum_term = sum(x[i]^2 / 4000 for i in 1:length(x))
    prod_term = prod(cos(x[i] / sqrt(i)) for i in 1:length(x))
    return sum_term - prod_term + 1
end

"""
    griewank_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Griewank function. Returns a vector of length n.
"""
function griewank_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    grad = zeros(T, n)
    for i in 1:n
        prod_term = prod(j == i ? 1 : cos(x[j] / sqrt(j)) for j in 1:n)
        grad[i] = 2 * x[i] / 4000 + sin(x[i] / sqrt(i)) * prod_term / sqrt(i)
    end
    return grad
end

const GRIEWANK_FUNCTION = TestFunction(
    griewank,
    griewank_gradient,
    Dict(
        :name => "griewank",
        :start => (n::Int=1) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int=1) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_value => 0.0,
        :properties => Set(["differentiable", "multimodal", "separable", "scalable"]),
        :lb => (n::Int=1) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(-600.0, n)
        end,
        :ub => (n::Int=1) -> begin
            n >= 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))
            fill(600.0, n)
        end,
        :description => "Griewank function: A multimodal function with many local minima.",
        :math => "f(x) = \\sum_{i=1}^n \\frac{x_i^2}{4000} - \\prod_{i=1}^n \\cos\\left(\\frac{x_i}{\\sqrt{i}}\\right) + 1"
    )
)