# src/functions/alpinen2.jl
# Purpose: Implements the AlpineN2 test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 05 September 2025

export ALPINEN2_FUNCTION, alpinen2, alpinen2_gradient

using LinearAlgebra
using ForwardDiff

"""
    alpinen2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the AlpineN2 function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or outside domain [0,10]^n.
"""
function alpinen2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(x .< 0) && throw(ArgumentError("Input vector must be in domain [0,10]^n"))
    any(x .> 10) && throw(ArgumentError("Input vector must be in domain [0,10]^n"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    prod = one(T)
    for xi in x
        prod *= sqrt(max(xi, eps(T))) * sin(xi)
    end
    return -prod
end

"""
    alpinen2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the AlpineN2 function. Throws `DomainError` if gradient computation
is undefined or numerically unstable (e.g., NaN, Inf, or excessively large values).
Throws `ArgumentError` if the input vector is empty or outside domain [0,10]^n.
"""
function alpinen2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(x .< 0) && throw(ArgumentError("Input vector must be in domain [0,10]^n"))
    any(x .> 10) && throw(ArgumentError("Input vector must be in domain [0,10]^n"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    prod = -alpinen2(x)  # Reuse function value
    grad = zeros(T, n)
    for i in 1:n
        xi = x[i]
        u_i = sqrt(xi) * sin(xi)
        du_i = sin(xi) / (2 * sqrt(xi)) + sqrt(xi) * cos(xi)
        grad_i = - (prod / u_i) * du_i
        if !isfinite(grad_i) || abs(grad_i) > 1e308 || !isfinite(du_i)
            throw(DomainError(x, "Gradient undefined or numerically unstable at x[$i] = $xi"))
        end
        grad[i] = grad_i
    end
    return grad
end

const ALPINEN2_FUNCTION = TestFunction(
    alpinen2,
    alpinen2_gradient,
    Dict(
        :name => "alpinen2",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("AlpineN2 requires at least 1 dimension"))
            fill(7.0, n)
        end,
        :min_position => (n::Int) -> fill(7.917052698245946, n),
        :min_value => (n::Int) -> - (2.8081311800070053)^n,
        :properties => Set(["multimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"]),
        :lb => (n::Int) -> zeros(n),
        :ub => (n::Int) -> fill(10.0, n),
        :in_molga_smutnicki_2005 => false,
        :description => "AlpineN2 function: Multimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: - (2.8081311800070053)^n at (7.917052698245946, ..., 7.917052698245946). Note: Negated product for minimization.",
        :math => "- \\prod_{i=1}^n \\sqrt{x_i} \\sin(x_i)"
    )
)