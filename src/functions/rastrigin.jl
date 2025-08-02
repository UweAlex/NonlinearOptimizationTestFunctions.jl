# src/functions/rastrigin.jl
# Purpose: Implements the Rastrigin test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: 16. Juli 2025, 07:19 AM CEST

    """
        rastrigin(x::AbstractVector)
    Computes the Rastrigin function value at point `x`. Requires at least 1 dimension.
    Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
    """
    function rastrigin(x::AbstractVector)
        length(x) >= 1 || throw(ArgumentError("Rastrigin requires at least 1 dimension"))
        T = eltype(x)
        any(isnan.(x)) && return T(NaN)
        any(isinf.(x)) && return T(Inf)
        n = length(x)
        return 10.0 * n + sum(x[i]^2 - 10.0 * cos(2 * π * x[i]) for i in 1:n)
    end

    """
        rastrigin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    Computes the gradient of the Rastrigin function. Returns a vector of length n.
    """
    function rastrigin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
        length(x) >= 1 || throw(ArgumentError("Rastrigin requires at least 1 dimension"))
        any(isnan.(x)) && return fill(T(NaN), length(x))
        any(isinf.(x)) && return fill(T(Inf), length(x))
        n = length(x)
        grad = zeros(T, n)
        @inbounds for i in 1:n
            grad[i] = 2.0 * x[i] + 20.0 * π * sin(2 * π * x[i])
        end
        return grad
    end

const RASTRIGIN_FUNCTION = TestFunction(
    rastrigin,
    rastrigin_gradient,
    Dict(
        :name => "rastrigin",
        :start => (n::Int=1) -> fill(1.0, n),
        :min_position => (n::Int=1) -> fill(0.0, n),
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "separable", "differentiable", "scalable", "bounded"]),
        :lb => (n::Int=1) -> fill(-5.12, n),
        :ub => (n::Int=1) -> fill(5.12, n),
        :description => "Rastrigin function: a multimodal, non-convex function with a global minimum at x = [0, ..., 0]. Bounds are [-5.12, 5.12].",
        :math => "f(x) = 10n + \\sum_{i=1}^n [x_i^2 - 10 \\cos(2\\pi x_i)]"
    )
)