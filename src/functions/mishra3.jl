# src/functions/mishra3.jl
# Purpose: Implementation of the Mishra Function 3 test function.
# Context: Non-scalable (n=2), continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*)=-0.184651 at x*=[-8.466613775046579, -9.998521308999999].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA3_FUNCTION, mishra3, mishra3_gradient

function mishra3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra Function 3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    inner = abs(x1^2 + x2)
    phi = sqrt(inner)
    u = cos(phi)
    sqrt_abs_u = sqrt(abs(u))
    T(0.01) * (x1 + x2) + sqrt_abs_u
end

function mishra3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra Function 3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    inner = x1^2 + x2
    abs_inner = abs(inner)
    phi = sqrt(abs_inner)
    u = cos(phi)
    abs_u = abs(u)
    sqrt_abs_u = sqrt(abs_u)
    
    grad = zeros(T, 2)
    grad[1] += T(0.01)
    grad[2] += T(0.01)
    
    if phi > zero(T) && abs_u > zero(T)
        # d phi / d var
        dphi_dx1 = (one(T)/(T(2) * phi)) * sign(inner) * (T(2) * x1)
        dphi_dx2 = (one(T)/(T(2) * phi)) * sign(inner) * one(T)
        
        # d u / d phi = -sin(phi)
        du_dphi = -sin(phi)
        
        # d sqrt(|u|) / d u = (1/(2 sqrt(|u|))) * sign(u)
        dsqrt_du = (one(T)/(T(2) * sqrt_abs_u)) * sign(u)
        
        dsqrt_dphi = dsqrt_du * du_dphi
        
        grad[1] += dsqrt_dphi * dphi_dx1
        grad[2] += dsqrt_dphi * dphi_dx2
    end
    # At singular points, gradient approx 0 for the nonlinear part
    grad
end

const MISHRA3_FUNCTION = TestFunction(
    mishra3,
    mishra3_gradient,
    Dict(
        :name => "mishra3",
        :description => "The Mishra Function 3. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left| \cos \left( \sqrt{ | x_1^2 + x_2 | } \right) \right|^{0.5} + 0.01 (x_1 + x_2) """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-8.466613775046579, -9.998521308999999],
        :min_value => () -> -0.184651333342989,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)