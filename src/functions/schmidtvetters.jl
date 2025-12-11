# src/functions/schmidtvetters.jl
# Purpose: Implementation of the Schmidt Vetters test function.
# Local minimum: f(x*)=2.9984462561992533 at x*=(0.78547, 0.78547, 0.78547).
# Bounds: 0 ≤ x_i ≤ 10.

export SCHMIDTVETTERS_FUNCTION, schmidtvetters, schmidtvetters_gradient

function schmidtvetters(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("schmidtvetters requires exactly 3 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x[2] == zero(T) && return T(Inf)  # Avoid division by zero in term3 (intentional singularity)
    
    x1, x2, x3 = x
    term1 = one(T) / (one(T) + (x1 - x2)^2)
    term2 = sin((π * x2 + x3) / 2)
    v = (x1 + x2) / x2 - 2
    term3 = exp(v^2)
    term1 + term2 + term3
end

function schmidtvetters_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("schmidtvetters requires exactly 3 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    x[2] == zero(T) && return fill(T(Inf), n)  # Avoid division by zero
    
    grad = zeros(T, 3)  # [RULE_GRADTYPE]
    x1, x2, x3 = x
    d = x1 - x2
    denom1 = one(T) + d^2
    denom1_sq = denom1^2
    s = (π * x2 + x3) / 2
    cos_s = cos(s)
    v = (x1 + x2) / x2 - 2
    exp_term = exp(v^2)
    
    # ∂f/∂x1
    grad[1] = -2 * d / denom1_sq + 2 * v * (one(T)/x2) * exp_term
    
    # ∂f/∂x2
    grad[2] = 2 * d / denom1_sq + (π / 2) * cos_s + 2 * v * (-x1 / x2^2) * exp_term
    
    # ∂f/∂x3
    grad[3] = (one(T)/2) * cos_s
    
    grad
end

const SCHMIDTVETTERS_FUNCTION = TestFunction(
    schmidtvetters,
    schmidtvetters_gradient,
    Dict(
        :name => "schmidtvetters",  # Dynamisch: "schmidtvetters" – exakt Dateiname [RULE_NAME_CONSISTENCY]
        :description => "Schmidt Vetters Function; Properties based on Jamil & Yang (2013, p. 116); Local minimum reported in source (rounded to 3, computed 2.998); global lower at boundary in wide bounds; partially differentiable due to singularity at x2=0; ursprünglich aus Schmidt & Vetter (1980).",
        :math => raw"""f(\mathbf{x}) = \frac{1}{1 + (x_1 - x_2)^2} + \sin\left( \frac{\pi x_2 + x_3}{2} \right) + e^{\left( \frac{x_1 + x_2}{x_2} - 2 \right)^2}. """,
        :start => () -> [1.0, 1.0, 1.0],
        :min_position => () ->  [7.07083412 , 10., 3.14159293] ,
        :min_value => () ->  0.19397252244395102,
        :properties => ["partially differentiable", "controversial" , "non-separable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 116)",
        :lb => () -> [0.0, 0.0, 0.0],
        :ub => () -> [10.0, 10.0, 10.0],
    )
)
