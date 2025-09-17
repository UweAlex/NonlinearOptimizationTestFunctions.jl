# src/functions/schwefel.jl
# Purpose: Implements the Schwefel test function with its analytical gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 15, 2025

export SCHWEFEL_FUNCTION, schwefel, schwefel_gradient

using LinearAlgebra

function schwefel(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
    any(isnan, x) && return T(NaN)
    any(isinf, x) && return T(Inf)
    sum_term = sum(x[i] * sin(sqrt(abs(x[i]))) for i in 1:n)
    return T(418.9828872724338) * n - sum_term
end

function schwefel_gradient(x::AbstractVector{T}) where {T<:Real}
    n = length(x)
    n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
    any(isnan, x) && return fill(T(NaN), n)
    any(isinf, x) && return fill(T(Inf), n)
    grad = zeros(T, n)
    for i in 1:n
        sqrt_abs_x = sqrt(abs(x[i]))
        if abs(x[i]) < 1e-10  # Handle x_i ≈ 0 for numerical stability
            grad[i] = 0.0
        else
            grad[i] = -sin(sqrt_abs_x) - sqrt_abs_x * cos(sqrt_abs_x) / 2
        end
    end
    return grad
end


const SCHWEFEL_FUNCTION = TestFunction(
    schwefel,
    schwefel_gradient,
    Dict(
        :name => "schwefel",
        :start => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_position => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(420.968746, n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["differentiable", "multimodal", "non-convex", "separable", "scalable", "continuous", "bounded"]),
        :lb => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(-500.0, n)
        end,
        :ub => (n::Int) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(500.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :dimension => -1,  # Scalable
        :description => raw"Schwefel function: A scalable, multimodal, non-convex, separable, differentiable, continuous, bounded test function with a global minimum at (420.968746, ..., 420.968746) with value 0.0. Non-differentiable at x_i = 0 due to the term √|x_i|. References: Jamil & Yang (2013), al-roomi.org.",
        :math => raw"f(x) = 418.9828872724338n - \sum_{i=1}^n x_i \sin(\sqrt{|x_i|})"
    )
)