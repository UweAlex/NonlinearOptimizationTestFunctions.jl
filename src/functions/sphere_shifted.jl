# src/functions/sphere_shifted.jl
# Purpose: Implementation of the Shifted Sphere test function.
# Global minimum: f(x*)=0.0 at x*=o (shift vector).
# Bounds: -100 ≤ x_i ≤ 100.

export SPHERE_SHIFTED_FUNCTION, sphere_shifted, sphere_shifted_gradient

function sphere_shifted(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_shifted requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Beispiel-Shift: o = ones(n) * 1.0; in Praxis random oder fixed
    o = fill(T(1.0), n)  # Beispiel-Shift
    sum_sq = zero(T)
    @inbounds for i in 1:n
        sum_sq += (x[i] - o[i])^2
    end
    sum_sq
end

function sphere_shifted_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sphere_shifted requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    o = fill(T(1.0), n)
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 2 * (x[i] - o[i])
    end
    grad
end

const SPHERE_SHIFTED_FUNCTION = TestFunction(
    sphere_shifted,
    sphere_shifted_gradient,
    Dict(
        :name => "sphere_shifted",
        :description => "Shifted Sphere benchmark function; Properties based on CEC 2005 Special Session.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n (x_i - o_i)^2.""",
        :start => (n::Int) -> zeros(n),
        :min_position => (n::Int) -> fill(1.0, n),  # Beispiel o
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "separable", "scalable", "convex", "unimodal"],
        :source => "CEC 2005 Special Session",
        :lb => (n::Int) -> fill(-100.0, n),
        :ub => (n::Int) -> fill(100.0, n),
    )
)
