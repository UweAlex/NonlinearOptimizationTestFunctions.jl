# src/functions/trid6.jl
# Purpose: Implementation of the Trid 6 test function.
# Global minimum: f(x*)=-50.0 at x*=[6.0, 10.0, 12.0, 12.0, 10.0, 6.0].
# Bounds: -36.0 ≤ x_i ≤ 36.0.

export TRID6_FUNCTION, trid6, trid6_gradient

function trid6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("trid6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # [RULE_NO_CONST_ARRAYS]: Local computation, no global arrays
    sum1 = zero(T)
    sum2 = zero(T)
    @inbounds for i in 1:6
        sum1 += (x[i] - 1)^2
    end
    @inbounds for i in 2:6
        sum2 += x[i] * x[i-1]
    end
    sum1 - sum2
end

function trid6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("trid6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 6)  # [RULE_GRADTYPE]
    @inbounds begin
        grad[1] = 2 * (x[1] - 1) - x[2]  # [RULE_TYPE_CONVERSION_MINIMAL]: No T(2.0)
        for i in 2:5
            grad[i] = 2 * (x[i] - 1) - x[i-1] - x[i+1]
        end
        grad[6] = 2 * (x[6] - 1) - x[5]
    end
    grad
end

const TRID6_FUNCTION = TestFunction(
    trid6,
    trid6_gradient,
    Dict(
        :name => "trid6",  # [RULE_NAME_CONSISTENCY]: Hardcoded
        :description => "Properties based on Jamil & Yang (2013, p. 35); originally from Hedar (2005).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{6} (x_i - 1)^2 - \sum_{i=2}^{6} x_i x_{i-1}.""",
        :start => () -> zeros(6),
        :min_position => () -> [6.0, 10.0, 12.0, 12.0, 10.0, 6.0],
        :min_value => () -> -50.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => () -> fill(-36.0, 6),
        :ub => () -> fill(36.0, 6),
    )
)

# Optional: Validation on load [RULE_NAME_CONSISTENCY]
@assert "trid6" == basename(@__FILE__)[1:end-3] "trid6: Dateiname mismatch!"