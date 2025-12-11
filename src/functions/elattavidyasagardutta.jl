# src/functions/elattavidyasagardutta.jl
# Purpose: Implementation of the El-Attar-Vidyasagar-Dutta test function.
# Context: Non-scalable, 4-dimensional, unimodal, non-separable function from El-Attar et al. (1979).
# Global minimum: f(x*)=0 at x*=[3,1,1,1].
# Bounds: -5.2 ≤ x_i ≤ 5.2.
# Last modified: October 22, 2025.

export ELATTAVIDYASAGARDUTTA_FUNCTION, elattavidyasagardutta, elattavidyasagardutta_gradient

using LinearAlgebra, ForwardDiff

"""
    elattavidyasagardutta(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the El-Attar-Vidyasagar-Dutta function value at point `x`. Requires exactly 4 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function elattavidyasagardutta(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("elattavidyasagardutta requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3, x4 = x
    a = x1^2 + x2 - 10
    a^2 + 5*(x3 - x4)^2 + (x2 - x3)^2 + 10*(x4 - 1)^2
end

"""
    elattavidyasagardutta_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the El-Attar-Vidyasagar-Dutta function. Returns a vector of length 4.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function elattavidyasagardutta_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("elattavidyasagardutta requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 4)
    any(isinf.(x)) && return fill(T(Inf), 4)
    
    x1, x2, x3, x4 = x
    a = x1^2 + x2 - 10
    grad = zeros(T, 4)
    @inbounds begin
        grad[1] = 4 * x1 * a
        grad[2] = 2 * a + 2 * (x2 - x3)
        grad[3] = 10 * (x3 - x4) - 2 * (x2 - x3)
        grad[4] = -10 * (x3 - x4) + 20 * (x4 - 1)
    end
    grad
end

const ELATTAVIDYASAGARDUTTA_FUNCTION = TestFunction(
    elattavidyasagardutta,
    elattavidyasagardutta_gradient,
    Dict(
        :name => "elattavidyasagardutta",
        :description => "El-Attar-Vidyasagar-Dutta test function from El-Attar et al. (1979), as standardized in Jamil & Yang (2013). Unimodal, non-separable function in 4 dimensions. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = (x_1^2 + x_2 - 10)^2 + 5(x_3 - x_4)^2 + (x_2 - x_3)^2 + 10(x_4 - 1)^2.""",
        :start => () -> [0.0, 0.0, 0.0, 0.0],
        :min_position => () -> [3.0, 1.0, 1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, Entry 16)",
        :lb => () -> [-5.2, -5.2, -5.2, -5.2],
        :ub => () -> [5.2, 5.2, 5.2, 5.2],
    )
)
