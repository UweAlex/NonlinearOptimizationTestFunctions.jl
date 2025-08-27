# src/functions/bartelsconn.jl
# Purpose: Implements the BartelsConn test function with its subgradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: August 25, 2025

export BARTELSCONN_FUNCTION, bartelsconn, bartelsconn_gradient

using LinearAlgebra
using ForwardDiff

"""
    bartelsconn(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the BartelsConn function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function bartelsconn(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("BartelsConn requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    u = x1^2 + x2^2 + x1 * x2
    v = sin(x1)
    w = cos(x2)
    return abs(u) + abs(v) + abs(w)
end

"""
    bartelsconn_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the subgradient of the BartelsConn function. Returns a vector of length 2.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
Throws `DomainError` if the function is not differentiable at the point (abs arguments are zero).
"""
function bartelsconn_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("BartelsConn requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    u = x1^2 + x2^2 + x1 * x2
    v = sin(x1)
    w = cos(x2)
    if isapprox(u, 0.0, atol=1e-10) || isapprox(v, 0.0, atol=1e-10) || isapprox(w, 0.0, atol=1e-10)
        throw(DomainError(x, "Bartels Conn function is not differentiable at this point (abs arguments are zero)"))
    end
    du_dx1 = 2 * x1 + x2
    du_dx2 = 2 * x2 + x1
    grad = zeros(T, 2)
    grad[1] = sign(u) * du_dx1 + sign(v) * cos(x1)
    grad[2] = sign(u) * du_dx2 - sign(w) * sin(x2)
    return grad
end

const BARTELSCONN_FUNCTION = TestFunction(
    bartelsconn,
    bartelsconn_gradient,
    Dict(
        :name => "bartelsconn",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => 1.0,
        :properties => Set(["multimodal", "non-convex", "non-separable", "partially differentiable", "bounded", "continuous"]),
        :lb => () -> [-500.0, -500.0],  # Korrigiert von [-5.0, -5.0]
        :ub => () -> [500.0, 500.0],    # Korrigiert von [5.0, 5.0]
        :in_molga_smutnicki_2005 => true,
        :description => "Bartels Conn function: Multimodal, non-convex, non-separable, partially differentiable, bounded test function with a global minimum at (0.0, 0.0). The subgradient is not well-defined at points where abs arguments are zero.",
        :math => "|x_1^2 + x_2^2 + x_1 x_2| + |\\sin(x_1)| + |\\cos(x_2)|"
    )
)