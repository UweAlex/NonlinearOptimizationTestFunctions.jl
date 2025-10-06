# src/functions/brad.jl
# Purpose: Implementation of the Brad test function.
# Context: Non-scalable (n=3), from Brad (1970), continuous, differentiable, non-separable, multimodal, bounded.
# Global minimum: f(x*)=0.00821487 at x*=[0.0824, 1.133, 2.3437].
# Bounds: -0.25 ≤ x1 ≤ 0.25, 0.01 ≤ x2, x3 ≤ 2.5.
# Last modified: September 23, 2025.

export BRAD_FUNCTION, brad, brad_gradient

# Constants
const U = collect(1:15)
const V = 16 .- U
const W = min.(U, V)
const Y = [0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39, 0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]

function brad(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Brad requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3 = x
    # Handle extremely small x2/x3 to avoid overflow/Inf in division
    if x2 < T(1e-200) || x3 < T(1e-200)
        return T(1e300)
    end
    
    sum_sq = zero(T)
    @inbounds for i in 1:15
        denom = V[i] * x2 + W[i] * x3
        denom == zero(T) && return T(Inf)  # Avoid division by zero
        residual = Y[i] - x1 - U[i] / denom
        sum_sq += residual^2
    end
    return sum_sq
end

function brad_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Brad requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)
    
    x1, x2, x3 = x
    # Handle extremely small x2/x3 to avoid overflow/Inf
    if x2 < T(1e-200) || x3 < T(1e-200)
        return fill(T(1e300), 3)
    end
    
    grad = zeros(T, 3)
    @inbounds for i in 1:15
        denom = V[i] * x2 + W[i] * x3
        denom == zero(T) && return fill(T(Inf), 3)
        residual = Y[i] - x1 - U[i] / denom
        inv_denom_sq = one(T) / (denom^2)
        grad[1] += 2 * residual * (-one(T))
        grad[2] += 2 * residual * (U[i] * V[i] * inv_denom_sq)
        grad[3] += 2 * residual * (U[i] * W[i] * inv_denom_sq)
    end
    return grad
end

const BRAD_FUNCTION = TestFunction(
    brad,
    brad_gradient,
    Dict(
        :name => "brad",
        :description => "Brad Function (Brad, 1970): A multimodal, non-separable test function for nonlinear optimization.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{15} \left( y_i - x_1 - \frac{u_i}{v_i x_2 + w_i x_3} \right)^2, \quad u_i = i, \ v_i = 16 - i, \ w_i = \min(u_i, v_i), \ \mathbf{y} = [0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39, 0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]^\top.""",
        :start => () -> [0.0, 1.0, 1.0],
       :min_position => () -> [0.0824105597447766, 1.1330360919212203, 2.3436951787453162],
  :min_value => () -> 0.008214877306578994,

        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :lb => () -> [-0.25, 0.01, 0.01],
        :ub => () -> [0.25, 2.5, 2.5],
    )
)