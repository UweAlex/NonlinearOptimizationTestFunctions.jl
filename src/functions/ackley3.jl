# src/functions/ackley3.jl
# Purpose: Implementation of the Ackley 3 test function.
# Global minimum: f(x*)= -195.629028238419 at x*=[0.682584587365898, -0.36075325513719].
# Bounds: -32 ≤ x_i ≤ 32.

export ACKLEY3_FUNCTION, ackley3, ackley3_gradient

function ackley3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ackley3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    r = sqrt(x[1]^2 + x[2]^2)
    -200.0 * exp(-0.02 * r) + 5.0 * exp(cos(3.0 * x[1]) + sin(3.0 * x[2]))
end

function ackley3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ackley3 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    r = sqrt(x[1]^2 + x[2]^2)
    grad = zeros(T, 2)
    if r != 0.0
        exp_term = exp(-0.02 * r)
        factor = 4.0 * exp_term / r
        grad[1] += factor * x[1]
        grad[2] += factor * x[2]
    end
    exp_term2 = exp(cos(3.0 * x[1]) + sin(3.0 * x[2]))
    grad[1] += -15.0 * sin(3.0 * x[1]) * exp_term2
    grad[2] += 15.0 * cos(3.0 * x[2]) * exp_term2
    grad
end

const ACKLEY3_FUNCTION = TestFunction(
    ackley3,
    ackley3_gradient,
    Dict{Symbol, Any}(
        :name => "ackley3",
        :description => "Ackley3 function. Properties based on Jamil & Yang (2013, p. 5); originally from Ackley (1987).",
        :math => raw"""f(\mathbf{x}) = -200 \exp(-0.02 \sqrt{x_1^2 + x_2^2}) + 5 \exp(\cos(3 x_1) + \sin(3 x_2)).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.682584587365898, -0.36075325513719],
        :min_value => () -> -195.629028238419,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 5)",
        :lb => () -> [-32.0, -32.0],
        :ub => () -> [32.0, 32.0],
    )
)

# Optional: Validierung beim Laden
@assert "ackley3" == basename(@__FILE__)[1:end-3] "ackley3: Dateiname mismatch!"