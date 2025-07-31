# src/functions/axis_parallel_hyper_ellipsoid.jl
# Purpose: Implements the AxisParallelHyperEllipsoid function.
# Last modified: 15. Juli 2025, 15:30 PM CEST

function axisparallelhyperellipsoid(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("AxisParallelHyperEllipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    result = sum(i * x[i]^2 for i in 1:length(x))
    return result
end

function axisparallelhyperellipsoid_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("AxisParallelHyperEllipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    result = [2.0 * i * x[i] for i in 1:length(x)]
    return result
end

const AXISPARALLELHYPERELLIPSOID_FUNCTION = TestFunction(
    axisparallelhyperellipsoid,
    axisparallelhyperellipsoid_gradient,
    Dict(
        :name => "axisparallelhyperellipsoid",
        :start => (n::Int=1) -> fill(1.0, n),
        :min_position => (n::Int=1) -> fill(0.0, n),
        :min_value => 0.0,
        :properties => Set(["convex", "differentiable", "separable", "scalable"]),
        :lb => (n::Int=1) -> fill(-Inf, n),
        :ub => (n::Int=1) -> fill(Inf, n),
        :description => "AxisParallelHyperEllipsoid function: a convex, differentiable function.",
        :math => "f(x) = \\sum_{i=1}^n i x_i^2"
    )
)