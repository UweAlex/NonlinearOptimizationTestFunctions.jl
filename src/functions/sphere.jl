# src/functions/sphere.jl
# Purpose: Implements the Sphere test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, used in optimization demos and tests.
# Last modified: 14. Juli 2025, 10:24 AM CEST

function sphere(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    return sum(x.^2)
end

function sphere_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    return 2.0 * x
end

const SPHERE_FUNCTION = TestFunction(
    sphere,
    sphere_gradient,
    Dict(
        :name => "sphere",
        :start => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(0.0, n)
        end,
        :min_position => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(0.0, n)
        end,
        :min_value => 0.0,
        :properties => Set(["unimodal", "convex", "separable", "differentiable", "scalable", "bounded"]),
        :lb => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(-5.12, n)
        end,
        :ub => (n::Int=2) -> begin
            n >= 2 || throw(ArgumentError("Sphere requires at least 2 dimensions"))
            fill(5.12, n)
        end,
        :description => "Sphere function: f(x) = Σ x_i^2",
        :math => "f(x) = \\sum_{i=1}^n x_i^2"
    )
)