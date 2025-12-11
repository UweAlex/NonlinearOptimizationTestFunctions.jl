# src/functions/dropwave.jl
# Purpose: Implementation of the Drop-Wave test function.
# Global minimum: f(x*)=-1.0 at x*=[0.0, 0.0].
# Bounds: -5.12 ≤ x_i ≤ 5.12.

export DROPWAVE_FUNCTION, dropwave, dropwave_gradient

function dropwave(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("dropwave requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    numerator = 1 + cos(12 * r)
    denominator = 0.5 * (x1^2 + x2^2) + 2
    -numerator / denominator
end

function dropwave_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("dropwave requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    r2 = x1^2 + x2^2
    r = sqrt(r2)
    if r == 0
        return grad
    end
    numerator = 1 + cos(12 * r)
    denominator = 0.5 * r2 + 2
    dr_numerator = -12 * sin(12 * r)
    dr_denominator = r
    factor = (12 * sin(12 * r) * (0.5 * r2 + 2) + (1 + cos(12 * r)) * r) / (r * denominator^2)
    grad[1] = factor * x1
    grad[2] = factor * x2
    grad
end

const DROPWAVE_FUNCTION = TestFunction(
    dropwave,
    dropwave_gradient,
    Dict{Symbol, Any}(
        :name => "dropwave",
        :description => "Properties based on Jamil & Yang (2013, p. 24); ursprünglich aus [Mutmaßliche Ursprungsquelle, falls bekannt].",
        :math => raw"""f(\mathbf{x}) = -\frac{1 + \cos(12 \sqrt{x_1^2 + x_2^2})}{0.5 (x_1^2 + x_2^2) + 2}.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> -1.0,
        :properties => ["multimodal", "non-convex", "non-separable", "differentiable", "bounded", "continuous"],
        :source => "Jamil & Yang (2013, p. 24)",
        :lb => () -> [-5.12, -5.12],
        :ub => () -> [5.12, 5.12],
    )
)

# Optional: Validierung beim Laden
