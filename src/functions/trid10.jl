# src/functions/trid10.jl
# Purpose: Implementation of the Trid 10 test function.
# Global minimum: f(x*)=-210.0 at x*=[10.0, 18.0, 24.0, 28.0, 30.0, 30.0, 28.0, 24.0, 18.0, 10.0].
# Bounds: -100.0 ≤ x_i ≤ 100.0.

export TRID10_FUNCTION, trid10, trid10_gradient

function trid10(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 10 && throw(ArgumentError("trid10 requires exactly 10 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # [RULE_NO_CONST_ARRAYS]: Local computation, no global arrays
    sum1 = zero(T)
    sum2 = zero(T)
    @inbounds for i in 1:10
        sum1 += (x[i] - 1)^2
    end
    @inbounds for i in 2:10
        sum2 += x[i] * x[i-1]
    end
    sum1 - sum2
end

function trid10_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 10 && throw(ArgumentError("trid10 requires exactly 10 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 10)  # [RULE_GRADTYPE]
    @inbounds begin
        grad[1] = 2 * (x[1] - 1) - x[2]  # [RULE_TYPE_CONVERSION_MINIMAL]: No T(2.0)
        for i in 2:9
            grad[i] = 2 * (x[i] - 1) - x[i-1] - x[i+1]
        end
        grad[10] = 2 * (x[10] - 1) - x[9]
    end
    grad
end

const TRID10_FUNCTION = TestFunction(
    trid10,
    trid10_gradient,
    Dict(
        :name => "trid10",  # [RULE_NAME_CONSISTENCY]: Hardcoded
        :description => "Properties based on Jamil & Yang (2013, p. 35); adapted for confirmed unimodal nature (no local minima per multiple sources); originally from Neumaier/Hedar.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{10} (x_i - 1)^2 - \sum_{i=2}^{10} x_i x_{i-1}.""",
        :start => () -> zeros(10),
        :min_position => () -> [10.0, 18.0, 24.0, 28.0, 30.0, 30.0, 28.0, 24.0, 18.0, 10.0],
        :min_value => () -> -210.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => () -> fill(-100.0, 10),
        :ub => () -> fill(100.0, 10),
    )
)

# Optional: Validation on load [RULE_NAME_CONSISTENCY]
