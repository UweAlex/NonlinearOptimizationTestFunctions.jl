# src/functions/ackley.jl
# Purpose: Implements the Ackley test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 14. Juli 2025, 17:05 PM CEST

"""
    ackley(x::AbstractVector)
Computes the Ackley function value at point `x`. Requires at least 1 dimension.
Default bounds are `[-5, 5]`, but `[-32.768, 32.768]` are recommended for benchmarks (use `meta[:lb](n, bounds="benchmark")`).
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
        return zeros(T, n)  # Sonderbehandlung für x = [0.0, ...]
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
        :properties => Set(["multimodal", "non-convex", "non-separable", "differentiable", "scalable", "bounded"]),
        :lb => (n::Int=1; bounds="default") -> bounds == "benchmark" ? fill(-32.768, n) : fill(-5.0, n),
        :ub => (n::Int=1; bounds="default") -> bounds == "benchmark" ? fill(32.768, n) : fill(5.0, n),
        :description => "Ackley function: a multimodal, non-convex function with a global minimum at x = [0, ..., 0]. Default bounds are [-5, 5], but [-32.768, 32.768] are recommended for standard benchmarks.",
        :math => "f(x) = -20 \\exp\\left(-0.2 \\sqrt{\\frac{1}{n} \\sum_{i=1}^n x_i^2}\\right) - \\exp\\left(\\frac{1}{n} \\sum_{i=1}^n \\cos(2\\pi x_i)\\right) + 20 + e"
    )
)