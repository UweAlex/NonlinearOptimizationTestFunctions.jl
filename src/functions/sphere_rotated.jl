# src/functions/sphere_rotated.jl
# Purpose: Implementation of the Rotated Sphere test function.
# Global minimum: f(x*)=0.0 at x*=(0, ..., 0).
# Bounds: -100 ≤ x_i ≤ 100.

export SPHERE_ROTATED_FUNCTION, sphere_rotated, sphere_rotated_gradient

function sphere_rotated(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_rotated requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Beispiel-Rotationsmatrix: Orthogonale Matrix (z.B. Identity für Simplizität; in Praxis random orthogonal)
    # Für Demo: Verwende eine feste Rotation, z.B. via Householder oder ähnlich; hier Identity als Placeholder
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2  # Rotated: Eigentlich (Q x)^2, aber für Identity = x^2
    end
    sum_sq  # Anpassen für echte Rotation
end

function sphere_rotated_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_rotated requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 2 * x[i]  # Anpassen für Rotation: 2 Q^T Q x = 2 x (da orthogonal)
    end
    grad
end

const SPHERE_ROTATED_FUNCTION = TestFunction(
    sphere_rotated,
    sphere_rotated_gradient,
    Dict(
        :name => "sphere_rotated",
        :description => "Rotated Sphere benchmark function; Properties based on CEC 2005 Problem Definitions and BBOB-Suiten.",
        :math => raw"""f(\mathbf{x}) = \| Q \mathbf{x} \|^2.""",
        :start => (n::Int) -> zeros(n),
        :min_position => (n::Int) -> zeros(n),
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "convex", "unimodal"],
        :source => "CEC 2005 Problem Definitions",
        :lb => (n::Int) -> fill(-100.0, n),
        :ub => (n::Int) -> fill(100.0, n),
    )
)

