# src/functions/dolan.jl
# Purpose: Implementation of the Dolan test function.
# Context: Non-scalable (n=5), from Jamil & Yang (2013), corrected minimum from Al-Roomi (2015).
# Global minimum: f(x* ) ≈ -529.8714 at x* ≈ [98.9643, 100, 100, 99.2243, -0.25].
# Bounds: -100 ≤ x_i ≤ 100.
# Last modified: September 25, 2025.
# Note: Ill-conditioned (Hessian cond ≈ 1.2e5); controversial minimum in literature.

export DOLAN_FUNCTION, dolan, dolan_gradient

function dolan(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("Dolan requires exactly 5 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3, x4, x5 = x
    theta = x4 + x5 - x1
    (x1 + 1.7 * x2) * sin(x1) - 1.5 * x3 - 0.1 * x4 * cos(theta) + 0.2 * x5^2 - x2 - 1
end

function dolan_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("Dolan requires exactly 5 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 5)
    any(isinf.(x)) && return fill(T(Inf), 5)
    
    x1, x2, x3, x4, x5 = x
    theta = x4 + x5 - x1
    sin_theta = sin(theta)
    cos_theta = cos(theta)
    
    grad = zeros(T, 5)
    grad[1] = (x1 + 1.7 * x2) * cos(x1) + sin(x1) - 0.1 * x4 * sin_theta
    grad[2] = 1.7 * sin(x1) - 1
    grad[3] = -1.5
    grad[4] = -0.1 * cos_theta + 0.1 * x4 * sin_theta
    grad[5] = 0.1 * x4 * sin_theta + 0.4 * x5
    grad
end

const DOLAN_FUNCTION = TestFunction(
    dolan,
    dolan_gradient,
    Dict(
        :name => "dolan",
        :description => "Dolan function (continuous, differentiable, non-separable, non-scalable, multimodal). Properties based on Jamil & Yang (2013). Global minimum corrected from literature (f=0 at [0,...] incorrect) using Al-Roomi (2015). Ill-conditioned Hessian.",
        :math => raw"""f(\mathbf{x}) = (x_1 + 1.7 x_2) \sin(x_1) - 1.5 x_3 - 0.1 x_4 \cos(x_4 + x_5 - x_1) + 0.2 x_5^2 - x_2 - 1""",
        :start => () -> [0.0, 0.0, 0.0, 0.0, 0.0],
        :min_position => () -> [98.964258312237106, 100.0, 100.0, 99.224323672554704, -0.249987527588471],
        :min_value => () -> -529.8714387324576,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "controversial"],
        :properties_source => "Jamil & Yang (2013)",
        :lb => () -> [-100.0, -100.0, -100.0, -100.0, -100.0],
        :ub => () -> [100.0, 100.0, 100.0, 100.0, 100.0],
    )
)