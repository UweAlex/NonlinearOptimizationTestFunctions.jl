# src/functions/bartelsconn.jl
# Purpose: Implements the Bartels Conn test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 21, 2025

export BARTELS_CONN_FUNCTION, bartelsconn, bartelsconn_gradient

using LinearAlgebra
using ForwardDiff

"""
    bartelsconn(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Bartels Conn function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bartelsconn(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    u = x[1]^2 + x[2]^2 + x[1] * x[2]
    v = sin(x[1])
    w = cos(x[2])
    return abs(u) + abs(v) + abs(w)
end

"""
    bartelsconn_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Bartels Conn function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bartelsconn_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    u = x[1]^2 + x[2]^2 + x[1] * x[2]
    su = sign(u)
    sv = sign(sin(x[1]))
    sw = sign(cos(x[2]))
    du1 = T(2.0) * x[1] + x[2]
    du2 = T(2.0) * x[2] + x[1]
    dv1 = cos(x[1])
    dv2 = T(0.0)
    dw1 = T(0.0)
    dw2 = -sin(x[2])
    grad1 = su * du1 + sv * dv1 + dw1
    grad2 = su * du2 + sv * dv2 + sw * dw2
    return [grad1, grad2]
end

const BARTELS_CONN_META = Dict(
    :name => "bartelsconn",
    :start => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
        [0.0, 0.0]
    end,
    :min_position => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
        [0.0, 0.0]
    end,
    :min_value => 1.0,
    :properties => Set(["multimodal", "non-convex", "non-separable", "continuous", "bounded"]), # Removed "non-differentiable"
    :lb => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
        [-500.0, -500.0]
    end,
    :ub => (n::Int) -> begin
        n != 2 && throw(ArgumentError("Bartels Conn requires exactly 2 dimensions"))
        [500.0, 500.0]
    end,
    :in_molga_smutnicki_2005 => false,
    :description => "Bartels Conn function: Continuous, non-separable, non-scalable, multimodal. Non-differentiable at points where abs arguments are zero.",
    :math => "\\f(x) = |x_1^2 + x_2^2 + x_1 x_2| + |\\sin(x_1)| + |\\cos(x_2)|"
)

const BARTELS_CONN_FUNCTION = TestFunction(
    bartelsconn,
    bartelsconn_gradient,
    BARTELS_CONN_META
)