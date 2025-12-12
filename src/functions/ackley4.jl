# src/functions/ackley4.jl
# Purpose: Implementation of the Ackley 4 test function.
# Global minimum: f(x*)= -5.297009385988958 at x*=[-1.5812643986108843, -0.7906319137820829].
# Bounds: -35 ≤ x_i ≤ 35.
export ACKLEY4_FUNCTION, ackley4, ackley4_gradient

function ackley4(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual,BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ackley4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end

    s = zero(T)
    @inbounds for i in 1:n-1
        term = exp(-0.2 * sqrt(x[i]^2 + x[i+1]^2)) + 3 * (cos(2 * x[i]) + sin(2 * x[i+1]))
        s += term
    end
    s
end

function ackley4_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual,BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("ackley4 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end

    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n-1
        x_i, x_ip1 = x[i], x[i+1]
        denom = sqrt(x_i^2 + x_ip1^2)
        exp_term = exp(-0.2 * denom)
        if denom > 0
            grad[i] += -0.2 * exp_term * x_i / denom
            grad[i+1] += -0.2 * exp_term * x_ip1 / denom
        end  # Handle denom=0 case (gradient contribution 0 when x_i=x_ip1=0)
        grad[i] += 3 * (-2 * sin(2 * x_i))
        grad[i+1] += 3 * (2 * cos(2 * x_ip1))
    end
    grad
end

const ACKLEY4_FUNCTION = TestFunction(
    ackley4,
    ackley4_gradient,
    Dict{Symbol,Any}(
        :name => "ackley4",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Modified Ackley Function (Ackley 4). Properties adapted from Jamil & Yang (2013, p. 5) for variant with √(x_i² + x_{i+1}²) in exponential and no x_i² term; originally from Rónkkónen (2009). Highly multimodal with local minimum near origin; global minimum approaches -6 near boundaries. Implemented as fixed n=2 due to limited metadata for higher dimensions.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{1} \left[ e^{-0.2 \sqrt{x_i^2 + x_{i+1}^2}} + 3 (\cos(2x_i) + \sin(2x_{i+1})) \right].""",
        :start => () -> [1.0, 1.0],  # Adjusted away from minimum [NEW RULE_START_AWAY_FROM_MIN]
        :min_position => () -> [-1.5812643986108843, -0.7906319137820829],
        :min_value => () -> -5.297009385988958,  # Local minimum; corrected via high-precision optimization
        :properties => ["bounded", "continuous", "controversial", "differentiable", "highly multimodal", "multimodal", "non-convex", "non-separable"],  # FIXED: Added "multimodal" and "non-convex" (required by "highly multimodal")
        :source => "Jamil & Yang (2013, p. 5)",
        :lb => () -> [-35.0, -35.0],
        :ub => () -> [35.0, 35.0],
    )
)