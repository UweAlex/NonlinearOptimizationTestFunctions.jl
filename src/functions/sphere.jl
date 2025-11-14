# src/functions/sphere.jl
# Purpose: Implements the Sphere test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: November 13, 2025

export SPHERE_FUNCTION, sphere, sphere_gradient

# Computes the Sphere function value at point `x`. Scalable to any dimension n >= 2.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# Throws `ArgumentError` if the input vector has less than 2 dimensions.
function sphere(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sum(x.^2)
end

# Computes the gradient of the Sphere function. Returns a vector of length n.
#
# Throws `ArgumentError` if the input vector has less than 2 dimensions.
function sphere_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    return 2.0 * x
end

const SPHERE_FUNCTION = TestFunction(
    sphere,
    sphere_gradient,
    Dict(
        :name => "sphere",
        :description => "Sphere function: f(x) = Σ x_i^2; Properties based on Jamil & Yang (2013, p. 33); adapted correcting multimodal to unimodal and adding convex based on standard analyses (e.g., sfu.ca/~ssurjano). Bounds adapted from sfu.ca; original in source: [0,10]^D.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D x_i^2.""",
        :start => (n::Int) -> begin
            n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
            fill(3.0, n)  # GEÄNDERT: NICHT fill(0.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
            fill(0.0, n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => ["bounded", "continuous", "convex", "differentiable", "scalable", "separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 33)",
        :default_n => 2,
        :lb => (n::Int) -> begin
            n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
            fill(-5.12, n)
        end,
        :ub => (n::Int) -> begin
            n < 2 && throw(ArgumentError("sphere requires at least 2 dimensions"))
            fill(5.12, n)
        end,
    )
)