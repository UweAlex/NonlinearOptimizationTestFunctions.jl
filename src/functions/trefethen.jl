# src/functions/trefethen.jl
# Purpose: Implementation of the Trefethen test function.
# Global minimum: f(x*)=-3.30686865 at x*=(-0.024403, 0.210612).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export TREFETHEN_FUNCTION, trefethen, trefethen_gradient

function trefethen(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("trefethen requires exactly 2 dimensions"))  # Hartkodiert [UPDATED RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # [RULE_NO_CONST_ARRAYS]: Local computation, no global arrays
    x1 = x[1]
    x2 = x[2]
    term1 = exp(sin(50 * x1))
    term2 = sin(60 * exp(x2))
    term3 = sin(70 * sin(x1))
    term4 = sin(sin(80 * x2))
    term5 = -sin(10 * (x1 + x2))
    term6 = 0.25 * (x1^2 + x2^2)  # [RULE_TYPE_CONVERSION_MINIMAL]: 0.25 instead of T(0.25)
    term1 + term2 + term3 + term4 + term5 + term6
end

function trefethen_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("trefethen requires exactly 2 dimensions"))  # Hartkodiert [UPDATED RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1 = x[1]
    x2 = x[2]
    @inbounds begin
        # df/dx1
        grad[1] = exp(sin(50 * x1)) * cos(50 * x1) * 50 + cos(70 * sin(x1)) * 70 * cos(x1) - cos(10 * (x1 + x2)) * 10 + 0.5 * x1
        # df/dx2
        grad[2] = cos(60 * exp(x2)) * 60 * exp(x2) + cos(sin(80 * x2)) * cos(80 * x2) * 80 - cos(10 * (x1 + x2)) * 10 + 0.5 * x2
    end
    grad
end

const TREFETHEN_FUNCTION = TestFunction(
    trefethen,
    trefethen_gradient,
    Dict(
        :name => "trefethen",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Properties based on Jamil & Yang (2013, p. 35); originally from MVF Library (Adorio & Diliman, 2005).",
        :math => raw"""f(\mathbf{x}) = e^{\sin(50 x_1)} + \sin(60 e^{x_2}) + \sin(70 \sin(x_1)) + \sin(\sin(80 x_2)) - \sin(10(x_1 + x_2)) + \frac{1}{4}(x_1^2 + x_2^2). """,
        :start => () -> zeros(2),
:min_position => () -> [-0.0244030799684242, 0.2106124278736910],
  :min_value => () -> -3.306868647475232,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
@assert "trefethen" == basename(@__FILE__)[1:end-3] "trefethen: Dateiname mismatch!"