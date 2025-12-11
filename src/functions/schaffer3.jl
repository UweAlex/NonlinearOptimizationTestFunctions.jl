# src/functions/schaffer3.jl
# Purpose: Implementation of the Schaffer Function No. 3 test function.
# Global minimum: f(x*)=0.00156685 at x*=(0, 1.253115).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHAFFER3_FUNCTION, schaffer3, schaffer3_gradient

function schaffer3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffer3 requires exactly 2 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    u = x1^2 - x2^2
    a = abs(u)
    b = cos(a)
    c = sin(b)^2
    r = x1^2 + x2^2
    q = 1 + 0.001 * r
    denom = q^2
    0.5 + c - 0.5 / denom
end

function schaffer3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffer3 requires exactly 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 2)  # [RULE_GRADTYPE]
    x1, x2 = x
    u = x1^2 - x2^2
    s_u = sign(u)
    a = abs(u)
    b = cos(a)
    sin_2b = sin(2 * b)
    sin_a = sin(a)
    r = x1^2 + x2^2
    q = one(T) + T(0.001) * r
    denom = q^2
    
    # ∂c/∂x1
    da_dx1 = s_u * 2 * x1
    db_dx1 = -sin_a * da_dx1
    dc_dx1 = sin_2b * db_dx1
    # ∂h/∂x1
    dh_dx1 = -0.002 * x1 / (q^3)
    grad[1] = dc_dx1 - dh_dx1
    
    # ∂c/∂x2
    da_dx2 = s_u * (-2 * x2)
    db_dx2 = -sin_a * da_dx2
    dc_dx2 = sin_2b * db_dx2
    # ∂h/∂x2
    dh_dx2 = -0.002 * x2 / (q^3)
    grad[2] = dc_dx2 - dh_dx2
    
    grad
end

const SCHAFFER3_FUNCTION = TestFunction(
    schaffer3,
    schaffer3_gradient,
    Dict(
        :name => "schaffer3",  # Dynamisch: "schaffer3" – exakt Dateiname [RULE_NAME_CONSISTENCY]
        :description => "Schaffer Function No. 3; Properties based on Jamil & Yang (2013, p. 28); ursprünglich aus Schaffer (1984). Note: Denominator interpreted as [1 + 0.001(x_1^2 + x_2^2)]^2 to match reported minimum.",
        :math => raw"""f(\mathbf{x}) = 0.5 + \sin^2(\cos |x_1^2 - x_2^2|) - \frac{0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}. """,
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.0, 1.253115587],
        :min_value => () -> 0.0015668553065719681,
        :properties => ["continuous", "differentiable", "non-separable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 28)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)
