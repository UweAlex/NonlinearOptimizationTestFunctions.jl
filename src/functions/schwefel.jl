# src/functions/schwefel.jl
# Purpose: Implements the Schwefel test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: 17. Juli 2025

"""
    schwefel(x::AbstractVector)
Computes the Schwefel function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function schwefel(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    result = 418.9829 * n - sum(x[i] * sin(sqrt(abs(x[i]))) for i in 1:n)
    return result
end

"""
    schwefel_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Schwefel function. Returns a vector of length n.
"""
function schwefel_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    result = Vector{T}(undef, n)
    for i in 1:n
        xi = x[i]
        abs_xi = abs(xi)
        sqrt_abs_xi = sqrt(abs_xi)
        sign_xi = xi >= 0 ? 1 : -1
        result[i] = -sin(sqrt_abs_xi) - (xi * cos(sqrt_abs_xi) * sign_xi) / (2 * sqrt_abs_xi)
    end
    return result
end

const SCHWEFEL_FUNCTION = TestFunction(
    schwefel,
    schwefel_gradient,
    Dict(
        :name => "schwefel",
        :start => (n::Int=2) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int=2) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(420.9687, n)
        end,
        :min_value => 0.0,
        :properties => Set(["multimodal", "non-convex", "separable", "differentiable", "scalable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(-500.0, n)
        end,
        :ub => (n::Int=2) -> begin
            n >= 1 || throw(ArgumentError("Schwefel requires at least 1 dimension"))
            fill(500.0, n)
        end,
        :in_molga_smutnicki_2005 => true,
        :description => "Schwefel function: Multimodal test function with a global minimum at approximately [420.9687, ..., 420.9687].",
        :math => "f(x) = 418.9829n - \\sum_{i=1}^n x_i \\sin(\\sqrt{|x_i|})"
    )
)