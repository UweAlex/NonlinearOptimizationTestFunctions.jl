# src/functions/helicalvalley.jl
# Purpose: Implementation of the Helical Valley test function.
# Context: Non-scalable, 3D, from Jamil & Yang (2013), function 64.
# Global minimum: f(x*)=0 at x*=[1, 0, 0].
# Bounds: -10 <= x_i <= 10.
# Last modified: September 26, 2025.
# Properties based on Jamil & Yang (2013).

export HELICALVALLEY_FUNCTION, helicalvalley, helicalvalley_gradient

function helicalvalley(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Helical Valley requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3 = x[1], x[2], x[3]
    r = sqrt(x1^2 + x2^2)
    if r == zero(T)
        theta = zero(T)
    else
        theta = atan(x2, x1) / (2 * pi * one(T))
    end
    a = x2 - 10 * theta
    b = r - one(T)
    100 * (a^2 + b^2) + x3^2
end

function helicalvalley_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Helical Valley requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)
    
    x1, x2, x3 = x[1], x[2], x[3]
    r2 = x1^2 + x2^2
    r = sqrt(r2)
    if r == zero(T)
        theta = zero(T)
        dtheta_dx1 = zero(T)
        dtheta_dx2 = zero(T)
    else
        theta = atan(x2, x1) / (2 * pi * one(T))
        denom = r2
        dtheta_dx1 = -x2 / (2 * pi * denom)
        dtheta_dx2 = x1 / (2 * pi * denom)
    end
    a = x2 - 10 * theta
    b = r - one(T)
    da_dx1 = -10 * dtheta_dx1
    da_dx2 = one(T) - 10 * dtheta_dx2
    db_dx1 = x1 / r
    db_dx2 = x2 / r
    if r == zero(T)
        db_dx1 = zero(T)
        db_dx2 = zero(T)
    end
    
    grad = zeros(T, 3)
    grad[1] = 200 * (a * da_dx1 + b * db_dx1)
    grad[2] = 200 * (a * da_dx2 + b * db_dx2)
    grad[3] = 2 * x3
    grad
end

const HELICALVALLEY_FUNCTION = TestFunction(
    helicalvalley,
    helicalvalley_gradient,
    Dict(
        :name => "helicalvalley",
        :description => "The Helical Valley function, a 3D multimodal non-separable function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = 100 \left[ (x_2 - 10\theta)^2 + \left(\sqrt{x_1^2 + x_2^2} - 1\right)^2 \right] + x_3^2, \quad \theta = \frac{1}{2\pi} \atantwo(x_2, x_1).""",
        :start => () -> [-1.0, 0.0, 0.0],
        :min_position => () -> [1.0, 0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [-10.0, -10.0, -10.0],
        :ub => () -> [10.0, 10.0, 10.0],
    )
)