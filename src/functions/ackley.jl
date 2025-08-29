# src/functions/ackley.jl
# Purpose: Implements the Ackley test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 29 August 2025, 08:30 AM CEST

"""
    ackley(x::AbstractVector)
Computes the Ackley function value at point `x`. Requires at least 1 dimension.
Standard bounds are [-32.768, 32.768]^n as per Molga & Smutnicki (2005).
Alternative bounds [-5, 5]^n can be used via `meta[:lb](n, bounds="alternative")`.
"""
function ackley(x::AbstractVector)
    length(x) >= 1 || throw(ArgumentError("Ackley requires at least 1 dimension"))
    T = eltype(x)
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    a = 20.0
    b = 0.2
    c = 2 * π
    sum_squares = sum(x.^2) / n
    sum_cos = sum(cos.(c * x)) / n
    return -a * exp(-b * sqrt(sum_squares)) - exp(sum_cos) + a + exp(1)
end

"""
    ackley_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Ackley function. Returns a vector of length n.
At the global minimum x = [0, ..., 0], the gradient is zero.
"""
function ackley_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Ackley requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    a = 20.0
    b = 0.2
    c = 2 * π
    sum_squares = sum(x.^2)
    if sum_squares == 0
        return zeros(T, n)  # Gradient is zero at x = [0, ..., 0]
    end
    sqrt_sum_squares = sqrt(sum_squares / n)
    term1 = (a * b / sqrt_sum_squares) * exp(-b * sqrt_sum_squares) / n
    term2 = exp(sum(cos.(c * x)) / n) * c / n
    grad = zeros(T, n)
    for i in 1:n
        grad[i] = term1 * x[i] + term2 * sin(c * x[i])
    end
    return grad
end

const ACKLEY_FUNCTION = TestFunction(
    ackley,
    ackley_gradient,
    Dict(
        :name => "ackley",
        :start => (n::Int=1) -> fill(1.0, n),
        :min_position => (n::Int=1) -> fill(0.0, n),
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "scalable", "bounded", "continuous"]),
        :lb => (n::Int=1; bounds="default") -> bounds == "alternative" ? fill(-5.0, n) : fill(-32.768, n),
        :ub => (n::Int=1; bounds="default") -> bounds == "alternative" ? fill(5.0, n) : fill(32.768, n),
        :in_molga_smutnicki_2005 => true,
        :description => "Ackley function: a multimodal, non-convex function with a global minimum at x = [0, ..., 0]. Standard bounds are [-32.768, 32.768]^n as per Molga & Smutnicki (2005). Alternative bounds [-5, 5]^n are available.",
        :math => "f(x) = -20 \\exp\\left(-0.2 \\sqrt{\\frac{1}{n} \\sum_{i=1}^n x_i^2}\\right) - \\exp\\left(\\frac{1}{n} \\sum_{i=1}^n \\cos(2\\pi x_i)\\right) + 20 + e"
    )
)

export ACKLEY_FUNCTION, ackley, ackley_gradient