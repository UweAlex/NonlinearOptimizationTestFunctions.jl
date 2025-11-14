# src/functions/watson.jl
# Purpose: Implementation of the standard Watson test function (MINPACK Problem 20).
# Global minimum: f(x*) ≈ 0.0023 at x* ≈ [-0.0157, 1.0124, -0.2330, 1.2604, -1.5137, 0.9930].
# Bounds: -5 ≤ x_i ≤ 5.
# Reference: Moré, J. J., Garbow, B. S., & Hillstrom, K. E. (1981). Testing Unconstrained Optimization Software. ACM TOMS, 7(1), 17–41.

export WATSON_FUNCTION, watson, watson_gradient

function watson(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("watson requires exactly 6 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    m = 29
    sum_total = zero(T)
    @inbounds for i in 1:m
        t = i / 29  # [RULE_TYPE_CONVERSION_MINIMAL]
        # sum1 = \sum_{j=2}^6 (j-1) x_j t^{j-2} = 1*x[2] + 2*t*x[3] + 3*t^2*x[4] + 4*t^3*x[5] + 5*t^4*x[6]
        t_pow = one(T)
        sum1 = x[2]  # j=2: 1 * t^0 * x2
        t_pow *= t
        sum1 += 2 * t_pow * x[3]  # j=3: 2 * t^1 * x3
        t_pow *= t
        sum1 += 3 * t_pow * x[4]  # j=4
        t_pow *= t
        sum1 += 4 * t_pow * x[5]  # j=5
        t_pow *= t
        sum1 += 5 * t_pow * x[6]  # j=6 (x[6] ist x[5] in 0-index)
        # sum2 = \sum_{j=1}^6 x_j t^{j-1} (Horner-Schema)
        sum2 = x[1] + t * (x[2] + t * (x[3] + t * (x[4] + t * (x[5] + t * x[6]))))
        term = sum1 - sum2^2 - one(T)
        sum_total += term^2
    end
    sum_total + x[1]^2
end

function watson_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("watson requires exactly 6 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    m = 29
    grad = zeros(T, n)
    @inbounds for i in 1:m
        t = i / 29
        # sum1 und sum2 wie in f
        t_pow = one(T)
        sum1 = x[2]
        t_pow *= t
        sum1 += 2 * t_pow * x[3]
        t_pow *= t
        sum1 += 3 * t_pow * x[4]
        t_pow *= t
        sum1 += 4 * t_pow * x[5]
        t_pow *= t
        sum1 += 5 * t_pow * x[6]
        sum2 = x[1] + t * (x[2] + t * (x[3] + t * (x[4] + t * (x[5] + t * x[6]))))
        term = sum1 - sum2^2 - one(T)
        # dsum1/dl = (l-1) * t^{l-2} for l=2..6, 0 for l=1
        # dsum2/dl = t^{l-1} for l=1..6
        for l in 1:6
            dsum1 = (l >= 2) ? (l - 1) * t^(l - 2) : zero(T)
            dsum2 = t^(l - 1)
            dterm = dsum1 - 2 * sum2 * dsum2  # Korrektur: kein 2*dsum1
            grad[l] += 2 * term * dterm
        end
    end
    grad[1] += 2 * x[1]  # Für +x1^2
    grad
end

const WATSON_FUNCTION = TestFunction(
    watson,
    watson_gradient,
    Dict{Symbol, Any}(
        :name => "watson",  # [RULE_NAME_CONSISTENCY]
        :description => "Standard Watson function (n=6); polynomial approximation residual model. Properties based on Moré et al. (1981). Jamil & Yang (2013, p. 37) formula variant inconsistent (missing (j-1) factors leads to wrong minimum ~154); adapted to verified standard form.",  # [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{29} \left[ \sum_{j=2}^{6} (j-1) x_j t_i^{j-2} - \left( \sum_{j=1}^{6} x_j t_i^{j-1} \right)^2 - 1 \right]^2 + x_1^2, \quad t_i = i / 29.""",
        :start => () -> zeros(6),
  :min_position => () ->  [ -0.01367625,  1.02929024, -0.33159222,  1.50042489, -1.75935227,  1.08739726 ],
  :min_value => () -> 0.00193306874741329,
       :properties => ["bounded", "continuous", "differentiable", "non-separable", "unimodal", "controversial"],  # "bounded" hinzugefügt
        :source => "Moré et al. (1981). Testing Unconstrained Optimization Software. ACM TOMS, 7(1), 17–41.",  # [RULE_PROPERTIES_SOURCE]
        :lb => () -> fill(-5.0, 6),
        :ub => () -> fill(5.0, 6),
    )
)

# Optional: Validierung beim Laden
@assert "watson" == basename(@__FILE__)[1:end-3] "watson: Dateiname mismatch!"