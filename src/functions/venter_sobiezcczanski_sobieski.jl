# src/functions/venter_sobiezcczanski_sobieski.jl
# Purpose: Implementation of the Venter Sobiezcczanski-Sobieski test function.
# Global minimum: f(x*) = -400.0 at x* = (0.0, 0.0)
# Bounds: -50.0 ≤ x_i ≤ 50.0
# Start point: [10.0, 10.0]  → NICHT das Minimum!

export VENTER_SOBIEZCCZANSKI_SOBIESKI_FUNCTION, venter_sobiezcczanski_sobieski, venter_sobiezcczanski_sobieski_gradient

function venter_sobiezcczanski_sobieski(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("venter_sobiezcczanski_sobieski requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    
    term1 = x1^2 - 100 * cos(x1)^2 - 100 * cos(x1^2 / 30)
    term2 = x2^2 - 100 * cos(x2)^2 - 100 * cos(x2^2 / 30)
    
    term1 + term2
end

function venter_sobiezcczanski_sobieski_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("venter_sobiezcczanski_sobieski requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x[1], x[2]
    grad = zeros(T, 2)
    
    grad[1] = 2 * x1 + 100 * sin(2 * x1) + (20 * x1 / 3) * sin(x1^2 / 30)
    grad[2] = 2 * x2 + 100 * sin(2 * x2) + (20 * x2 / 3) * sin(x2^2 / 30)
    
    grad
end

const VENTER_SOBIEZCCZANSKI_SOBIESKI_FUNCTION = TestFunction(
    venter_sobiezcczanski_sobieski,
    venter_sobiezcczanski_sobieski_gradient,
    Dict{Symbol, Any}(
        :name => "venter_sobiezcczanski_sobieski",
        :description => "The Venter Sobiezcczanski-Sobieski function; Properties based on Jamil & Yang (2013, p. 37); originally from Begambre and Laier (2009). Multimodal with multiple local minima due to cosine terms.",
        :math => raw"""f(\mathbf{x}) = x_1^2 - 100 \cos^2(x_1) - 100 \cos\left(\frac{x_1^2}{30}\right) + x_2^2 - 100 \cos^2(x_2) - 100 \cos\left(\frac{x_2^2}{30}\right). """,
        :start => () -> [10.0, 10.0],  # GEÄNDERT: NICHT [0.0, 0.0]
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> -400.0,
        :properties => ["bounded", "continuous", "differentiable", "separable"],
        :source => "Jamil & Yang (2013, p. 37)",
        :lb => () -> [-50.0, -50.0],
        :ub => () -> [50.0, 50.0],
    )
)

# Validierung beim Laden
@assert "venter_sobiezcczanski_sobieski" == basename(@__FILE__)[1:end-3] "venter_sobiezcczanski_sobieski: Dateiname mismatch!"