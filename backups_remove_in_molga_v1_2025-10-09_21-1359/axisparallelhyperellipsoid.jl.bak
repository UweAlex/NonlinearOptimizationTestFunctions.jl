# src/functions/axis_parallel_hyper_ellipsoid.jl
# Purpose: Implements the Axis Parallel Hyper-Ellipsoid function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: 12 September 2025

export AXISPARALLELHYPERELLIPSOID_FUNCTION, axisparallelhyperellipsoid, axisparallelhyperellipsoid_gradient

using LinearAlgebra
using ForwardDiff

"""
    axisparallelhyperellipsoid(x::AbstractVector)
Computes the Axis Parallel Hyper-Ellipsoid function value at point `x`. Requires at least 1 dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function axisparallelhyperellipsoid(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) >= 1 || throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return eltype(x)(NaN)
    any(isinf.(x)) && return eltype(x)(Inf)
    
    result = sum(i * x[i]^2 for i in 1:length(x))
    return result
end

"""
    axisparallelhyperellipsoid_gradient(x::AbstractVector)
Computes the gradient of the Axis Parallel Hyper-Ellipsoid function. Returns a vector of length n.
"""
function axisparallelhyperellipsoid_gradient(x::AbstractVector)
    eltype(x) <: Union{Real, ForwardDiff.Dual} || throw(ArgumentError("Input vector must have elements of type Real or ForwardDiff.Dual"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    length(x) >= 1 || throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return fill(eltype(x)(NaN), length(x))
    any(isinf.(x)) && return fill(eltype(x)(Inf), length(x))
    
    result = [2.0 * i * x[i] for i in 1:length(x)]
    return result
end

const AXISPARALLELHYPERELLIPSOID_FUNCTION = TestFunction(
    axisparallelhyperellipsoid,
    axisparallelhyperellipsoid_gradient,
    Dict(
        :name => "axisparallelhyperellipsoid",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_value => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
            0.0
        end,
        :properties => Set(["convex", "differentiable", "separable", "scalable", "continuous", "bounded"]),
        :default_n => 2,
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
            fill(-5.12, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Axis Parallel Hyper-Ellipsoid requires at least 1 dimension"))
            fill(5.12, n)
        end,
        :description => "Axis Parallel Hyper-Ellipsoid function: Convex, differentiable, separable, scalable, continuous test function with a global minimum of 0.0 at x = [0, ..., 0] for any n ≥ 1. Typically tested with bounds [-5.12, 5.12]^n, making it bounded for practical purposes. See [Jamil & Yang (2013)] for details.",
        :math => "\\sum_{i=1}^n i x_i^2",
        :reference => "[Jamil & Yang (2013)]"
    )
)
