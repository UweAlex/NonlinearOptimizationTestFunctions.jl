# src/functions/rastrigin.jl
# Purpose: Implements the Rastrigin test function with its gradient.
# Global minimum: f(x*) = 0 at x* = [0, ..., 0]
# Bounds: -5.12 ≤ x_i ≤ 5.12 (standard)

export RASTRIGIN_FUNCTION, rastrigin, rastrigin_gradient

using LinearAlgebra
using ForwardDiff

function rastrigin(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Rastrigin requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    sum = zero(T)
    @inbounds for i in 1:n
        sum += x[i]^2 - 10 * cos(2 * π * x[i])
    end
    10 * n + sum
end

function rastrigin_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Rastrigin requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 2 * x[i] + 20 * π * sin(2 * π * x[i])
    end
    grad
end

const RASTRIGIN_FUNCTION = TestFunction(
    rastrigin,
    rastrigin_gradient,
    Dict{Symbol, Any}(
        :name         => "rastrigin",
        :description  => "Rastrigin function – highly multimodal and strongly deceptive. " *
                         "The regular arrangement of deep local minima systematically misleads " *
                         "gradient-based and local search methods away from the global minimum at zero. " *
                         "Classic example of a deceptive function in global optimization literature.",
        :math         => raw"f(\mathbf{x}) = 10n + \sum_{i=1}^n \left[ x_i^2 - 10 \cos(2\pi x_i) \right]",
        :start        => (n::Int) -> fill(2.0, n),           # weit weg vom Minimum
        :min_position => (n::Int) -> zeros(n),
        :min_value    => (n::Int) -> 0.0,
        :properties   => ["multimodal", "non-convex", "separable", "differentiable",
                           "scalable", "bounded", "continuous", "deceptive"],
        :default_n    => 10,
        :lb           => (n::Int) -> fill(-5.12, n),
        :ub           => (n::Int) -> fill( 5.12, n),
        :source       => "Molga & Smutnicki (2005), p. 24; " *
                         "Goldberg (1989) – classic deceptive benchmark; " *
                         "Jamil & Yang (2013), p. 88"
    )
)