# src/functions/sphere.jl
# Purpose: Implements the Sphere test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions, used in optimization demos and tests.
# Last modified: 14. Juli 2025, 10:24 AM CEST

# Computes the Sphere function value at point `x`. Scalable to any dimension n >= 2.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# Throws `ArgumentError` if the input vector has less than 2 dimensions.
function sphere(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sum(x.^2)
end #function

# Computes the gradient of the Sphere function. Returns a vector of length n.
#
# Throws `ArgumentError` if the input vector has less than 2 dimensions.
function sphere_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    return 2.0 * x
end #function

const SPHERE_FUNCTION = TestFunction(
    sphere,
    sphere_gradient,
    Dict(
        :name => "sphere",
        :start => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(0.0, n)
        end, #function
        :min_position => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(0.0, n)
        end, #function
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["unimodal", "convex", "separable", "differentiable", "scalable","bounded","continuous"]),
        :lb => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(-5.12, n)
        end, #function
        :ub => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(5.12, n)
        end, #function
        :description => "Sphere function: f(x) = Σ x_i^2",
        :math => "f(x) = \\sum_{i=1}^n x_i^2"
    )
)