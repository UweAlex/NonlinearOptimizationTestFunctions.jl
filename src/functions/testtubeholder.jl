# src/functions/testtubeholder.jl
# Purpose: Implementation of the Testtube Holder test function.
# Global minimum: f(x*)=-10.8723 at x*=[π/2, 0] (and symmetric [-π/2, 0]).
# Bounds: -10 ≤ x_i ≤ 10.

export TESTTUBEHOLDER_FUNCTION, testtubeholder, testtubeholder_gradient

function testtubeholder(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("testtubeholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    theta = (x1^2 + x2^2) / 200
    cos_theta = cos(theta)
    abs_cos = abs(cos_theta)
    exp_term = exp(abs_cos)
    sin_cos_prod = sin(x1) * cos(x2)
    g = sin_cos_prod * exp_term
    f_val = -4 * g
    f_val
end

function testtubeholder_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("testtubeholder requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1, x2 = x[1], x[2]
    theta = (x1^2 + x2^2) / 200
    cos_theta = cos(theta)
    sin_theta = sin(theta)
    abs_cos = abs(cos_theta)
    sign_cos = sign(cos_theta)
    exp_term = exp(abs_cos)
    sin_cos_prod = sin(x1) * cos(x2)
    g = sin_cos_prod * exp_term
    
    # Common factor: -4
    common = -T(4)
    
    # d_abs_cos_dtheta = -sin_theta * sign_cos (chain rule for |cos theta|)
    d_abs_dtheta = -sin_theta * sign_cos
    
    # dtheta_dx1 = x1 / 100, dtheta_dx2 = x2 / 100
    dtheta_dx1 = x1 / 100
    dtheta_dx2 = x2 / 100
    
    # For dg/dx1: d(sin x1 cos x2)/dx1 * exp + sin_cos_prod * d exp / dx1
    # d exp / dx1 = exp * d_abs_dtheta * dtheta_dx1
    d_exp_dx1 = exp_term * d_abs_dtheta * dtheta_dx1
    dg_dx1 = cos(x1) * cos(x2) * exp_term + sin_cos_prod * d_exp_dx1
    grad[1] = common * dg_dx1
    
    # Symmetric for dx2
    d_exp_dx2 = exp_term * d_abs_dtheta * dtheta_dx2
    dg_dx2 = -sin(x1) * sin(x2) * exp_term + sin_cos_prod * d_exp_dx2
    grad[2] = common * dg_dx2
    
    grad
end

const TESTTUBEHOLDER_FUNCTION = TestFunction(
    testtubeholder,
    testtubeholder_gradient,
    Dict(
        :name => "testtubeholder",
        :description => "Two global minima due to sign choices; Properties based on Jamil & Yang (2013, p. 34); Contains absolute value terms; originally from literature circa 2006.",
        :math => raw"""f(\mathbf{x}) = -4 \sin(x_1) \cos(x_2) \exp\left( \left| \cos\left( \frac{x_1^2 + x_2^2}{200} \right) \right| \right).""",
        :start => () -> [0.0, 0.0],
    :min_position => () -> [1.5706026141696665, 4.534236385313213e-12],
  :min_value => () -> -10.872300105622745,
      :properties => ["bounded", "continuous", "multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 34)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validation on load
@assert "testtubeholder" == basename(@__FILE__)[1:end-3] "testtubeholder: Filename mismatch!"