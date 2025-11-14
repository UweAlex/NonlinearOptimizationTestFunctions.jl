# src/functions/ursem4.jl
# Purpose: Implementation of the Ursem No. 4 test function.
# Global minimum: f(x*)=-1.5 at x*=(0.0, 0.0).
# Bounds: -2 ≤ x_i ≤ 2.

export URSEM4_FUNCTION, ursem4, ursem4_gradient

function ursem4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1 = x[1]
    x2 = x[2]
    
    r = sqrt(x1^2 + x2^2)
    sin_term = sin(0.5 * π * x1 + 0.5 * π)
    
    -3 * sin_term * (2 - r) / 4
end

function ursem4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ursem4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)
    x1 = x[1]
    x2 = x[2]
    r = sqrt(x1^2 + x2^2)
    
    if r == 0
        return zeros(T, 2)  # Define as zero at origin for testing/optimization purposes
    end
    
    sin_term = sin(0.5 * π * x1 + 0.5 * π)
    cos_term = cos(0.5 * π * x1 + 0.5 * π)
    
    common_factor = -3 / 4
    
    grad[1] = common_factor * (cos_term * 0.5 * π * (2 - r) + sin_term * (-x1 / r))
    grad[2] = common_factor * (sin_term * (-x2 / r))
    
    grad
end

const URSEM4_FUNCTION = TestFunction(
    ursem4,
    ursem4_gradient,
    Dict{Symbol, Any}(
        :name => "ursem4",
        :description => "The Ursem No. 4 function; Properties based on Jamil & Yang (2013, p. 36); Contains square root terms making it non-differentiable at the origin.",
        :math => raw"""f(\mathbf{x}) = -\frac{3}{4} \sin\left(0.5 \pi x_1 + 0.5 \pi\right) \left(2 - \sqrt{x_1^2 + x_2^2}\right). """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> -1.5,
        :properties => ["bounded", "continuous", "partially differentiable", "multimodal", "non-convex", "non-separable"],
        :source => "Jamil & Yang (2013, p. 36)",
        :lb => () -> [-2.0, -2.0],
        :ub => () -> [2.0, 2.0],
    )
)

# Optional: Validierung beim Laden
@assert "ursem4" == basename(@__FILE__)[1:end-3] "ursem4: Dateiname mismatch!"