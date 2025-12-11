# src/functions/carromtable.jl
# Purpose: Implementation of the Carrom Table test function.
# Global minimum: f(x*)=-24.1568155 at x*=[9.646157266348881, 9.646134286497169] (one of four symmetric points).
# Bounds: -10 ≤ x_i ≤ 10.

export CARROMTABLE_FUNCTION, carromtable, carromtable_gradient

function carromtable(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("carromtable requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    r = sqrt(x1^2 + x2^2)
    r == zero(T) && return zero(T)  # Avoid div by zero, though bounds prevent r=0 exactly
    abs_term = abs(1 - r / π)
    exp_term = exp(abs_term)
    cos_prod = cos(x1) * cos(x2)
    g = cos_prod * exp_term
    f_val = -g^2 / 30
    f_val
end

function carromtable_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("carromtable requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1, x2 = x[1], x[2]
    r = sqrt(x1^2 + x2^2)
    if r == zero(T)
        return grad  # Gradient at origin is zero by symmetry
    end
    u = 1 - r / π
    sign_u = sign(u)
    abs_term = abs(u)
    exp_term = exp(abs_term)
    cos_prod = cos(x1) * cos(x2)
    g = cos_prod * exp_term
    
    # Common factor for df = -1/15 * g * dg
    common = -g / 15
    
    # dg/dx1 = -sin(x1) cos(x2) exp + cos(x1) cos(x2) exp * d(abs_term)/dx1
    d_abs_dx1 = sign_u * (-1/π * x1 / r)
    dg_dx1 = -sin(x1) * cos(x2) * exp_term + cos_prod * exp_term * d_abs_dx1
    grad[1] = common * dg_dx1
    
    # Symmetric for dx2
    d_abs_dx2 = sign_u * (-1/π * x2 / r)
    dg_dx2 = -cos(x1) * sin(x2) * exp_term + cos_prod * exp_term * d_abs_dx2
    grad[2] = common * dg_dx2
    
    grad
end

const CARROMTABLE_FUNCTION = TestFunction(
    carromtable,
    carromtable_gradient,
    Dict(
        :name => "carromtable",
        :description => "Four global minima due to sign choices; Properties based on Jamil & Yang (2013, p. 34); originally from Mishra (2004).",
        :math => raw"""f(\mathbf{x}) = -\frac{\left[ \left( \cos(x_1) \cos(x_2) \exp \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right)^2 \right]}{30}.""",
        :start => () -> [0.0, 0.0],
   :min_position => () -> [9.646167670438874, 9.646167670438874],
  :min_value => () -> -24.156815547391208,
       :properties => ["continuous", "differentiable", "multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 34)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validation on load
