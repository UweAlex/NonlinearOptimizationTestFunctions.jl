# src/functions/sphere_noisy.jl
# Purpose: Implementation of the Noisy Sphere test function.
# Global minimum: f(x*)≈0.0 at x*=(0, ..., 0).
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: December 11, 2025.

export SPHERE_NOISY_FUNCTION, sphere_noisy, sphere_noisy_gradient

function sphere_noisy(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_noisy requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
    end
    sum_sq + rand(T) # U[0,1) Noise
end

function sphere_noisy_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_noisy requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 2 * x[i] # Deterministisch (Noise nur in f)
    end
    grad
end

const SPHERE_NOISY_FUNCTION = TestFunction(
    sphere_noisy,
    sphere_noisy_gradient,
    Dict(
        :name => "sphere_noisy",
        :description => "Noisy Sphere benchmark function with additive uniform [0,1) noise; Properties based on BBOB f101 / Nevergrad 'NoisySphere'. Additive uniform [0,1) noise.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \epsilon, \epsilon \sim U[0,1].""",
        :start => (n::Int) -> zeros(n),
        :min_position => (n::Int) -> zeros(n),
        :min_value => (n::Int) -> 0.0, # Deterministischer Teil
        :default_n => 2,
        :properties => ["continuous", "separable", "scalable", "convex", "has_noise"], # 'differentiable' entfernt
        :source => "BBOB f101 / Nevergrad",
        :lb => (n::Int) -> fill(-100.0, n),
        :ub => (n::Int) -> fill(100.0, n),
    )
)