# src/functions/damavandi.jl
# Purpose: Implementation of the Damavandi test function.
# Context: Non-scalable, 2D, from Damavandi & Safavi-Naeini (2005).
# Global minimum: f(x*)=0 at x*=[2, 2].
# Bounds: 0 ≤ x_i ≤ 14.
# Last modified: September 24, 2025.

export DAMAVANDI_FUNCTION, damavandi, damavandi_gradient

function damavandi(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Damavandi requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    a = x1 - 2
    b = x2 - 2
    
    sinc_a = abs(a) < 1e-10 ? one(T) : sin(pi * a) / (pi * a)
    sinc_b = abs(b) < 1e-10 ? one(T) : sin(pi * b) / (pi * b)
    g = sinc_a * sinc_b
    u = abs(g)^5
    p = one(T) - u
    h = 2 + (x1 - 7)^2 + 2 * (x2 - 7)^2
    return p * h
end

function damavandi_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Damavandi requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    a = x1 - 2
    b = x2 - 2
    h = 2 + (x1 - 7)^2 + 2 * (x2 - 7)^2
    dh1 = 2 * (x1 - 7)
    dh2 = 4 * (x2 - 7)
    
    sinc_a = abs(a) < 1e-10 ? one(T) : sin(pi * a) / (pi * a)
    sinc_b = abs(b) < 1e-10 ? one(T) : sin(pi * b) / (pi * b)
    g = sinc_a * sinc_b
    
    dsinc_a = abs(a) < 1e-10 ? zero(T) : (pi * a * cos(pi * a) - sin(pi * a)) / (pi * a^2)
    dsinc_b = abs(b) < 1e-10 ? zero(T) : (pi * b * cos(pi * b) - sin(pi * b)) / (pi * b^2)
    
    dg_da = dsinc_a * sinc_b
    dg_db = dsinc_b * sinc_a
    
    u = abs(g)^5
    p = one(T) - u
    
    sgn_g = g == zero(T) ? one(T) : g / abs(g)
    du_da = 5 * abs(g)^4 * sgn_g * dg_da
    du_db = 5 * abs(g)^4 * sgn_g * dg_db
    dp_da = -du_da
    dp_db = -du_db
    
    df_da = dp_da * h + p * dh1
    df_db = dp_db * h + p * dh2
    
    grad = zeros(T, 2)
    grad[1] = df_da
    grad[2] = df_db
    return grad
end

const DAMAVANDI_FUNCTION = TestFunction(
    damavandi,
    damavandi_gradient,
    Dict(
        :name => "damavandi",
        :description => "Damavandi function (Damavandi & Safavi-Naeini, 2005): A multimodal, non-separable 2D function with a global minimum of 0 at (2,2). Features a deceptive landscape due to the sinc-like terms.",
        :math => raw"""f(\mathbf{x}) = \left[1 - \left| \frac{\sin[\pi (x_1 - 2)]\sin[\pi (x_2 - 2)]}{\pi^2 (x_1 - 2)(x_2 - 2)} \right|^5 \right] \left[ 2 + (x_1 - 7)^2 + 2(x_2 - 7)^2 \right] """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [2.0, 2.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :lb => () -> [0.0, 0.0],
        :ub => () -> [14.0, 14.0],
    )
)