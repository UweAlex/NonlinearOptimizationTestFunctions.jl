# src/functions/wayburnseader1.jl
# Purpose: Implementation of the Wayburn Seader 1 test function.
# Global minimum: f(x*)=0.0 at x*=[1.0, 2.0].
# Bounds: -5.0 ≤ x_i ≤ 5.0.

export WAYBURNSEADER1_FUNCTION, wayburnseader1, wayburnseader1_gradient

function wayburnseader1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader1 requires exactly 2 dimensions"))  # Hartkodiert [UPDATED RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    a = x[1]^6 + x[2]^4 - 17
    b = 2 * x[1] + x[2] - 4
    a^2 + b^2
end

function wayburnseader1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("wayburnseader1 requires exactly 2 dimensions"))  # Hartkodiert [UPDATED RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    a = x[1]^6 + x[2]^4 - 17
    b = 2 * x[1] + x[2] - 4
    grad[1] = 2 * a * 6 * x[1]^5 + 2 * b * 2
    grad[2] = 2 * a * 4 * x[2]^3 + 2 * b
    grad
end

const WAYBURNSEADER1_FUNCTION = TestFunction(
    wayburnseader1,
    wayburnseader1_gradient,
    Dict{Symbol, Any}(
        :name => "wayburnseader1",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "The Wayburn Seader 1 function; Properties based on Jamil & Yang (2013, p. 37); originally from Wayburn and Seader (1987). Multiple global minima at (1,2) and approximately (1.597, 0.806). Marked as scalable in source, but formula only uses first 2 variables; adapted to fixed n=2.",
        :math => raw"""f(\mathbf{x}) = (x_1^6 + x_2^4 - 17)^2 + (2x_1 + x_2 - 4)^2.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 2.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 37)",
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0],
    )
)

# Optional: Validierung beim Laden
@assert "wayburnseader1" == basename(@__FILE__)[1:end-3] "wayburnseader1: Dateiname mismatch!"