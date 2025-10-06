# src/functions/braninrcos2.jl
# Purpose: Implementation of the Branin RCOS Function 2 test function.
# Context: Non-scalable (n=2), from Muntenau and Lazarescu (1998), continuous, differentiable, non-separable, multimodal, bounded.
# Global minimum: f(x*)=-39.19565 at x*≈[-3.172, 12.586] (validated via optimization; paper states 5.559037 at [-3.2, 12.53] – likely transcription error in source).
# Bounds: -5 ≤ x_i ≤ 15.
# Last modified: September 23, 2025.

export BRANINRCOS2_FUNCTION, braninrcos2, braninrcos2_gradient

function braninrcos2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Branin RCOS 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    pi = T(π)
    a = T(5.1) / (T(4) * pi^2)
    b = T(5) / pi
    A = x2 - a * x1^2 + b * x1 - T(6)
    sq1 = A^2
    B = T(1) - T(1)/(T(8) * pi)
    r2 = x1^2 + x2^2
    ln_term = log(r2 + T(1))
    cos_term = B * cos(x1) * cos(x2) * ln_term
    return sq1 + T(10) * cos_term + T(10)
end

function braninrcos2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Branin RCOS 2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x
    pi = T(π)
    a = T(5.1) / (T(4) * pi^2)
    b = T(5) / pi
    A = x2 - a * x1^2 + b * x1 - T(6)
    dA_dx1 = -T(2) * a * x1 + b
    dA_dx2 = T(1)
    B = T(1) - T(1)/(T(8) * pi)
    r2 = x1^2 + x2^2
    ln_term = log(r2 + T(1))
    d_ln_dx1 = T(2) * x1 / (r2 + T(1))
    d_ln_dx2 = T(2) * x2 / (r2 + T(1))
    cos_prod = cos(x1) * cos(x2)
    d_cos_prod_dx1 = -sin(x1) * cos(x2)
    d_cos_prod_dx2 = cos(x1) * -sin(x2)
    
    cos_term = B * cos_prod * ln_term
    d_cos_term_dx1 = B * (d_cos_prod_dx1 * ln_term + cos_prod * d_ln_dx1)
    d_cos_term_dx2 = B * (d_cos_prod_dx2 * ln_term + cos_prod * d_ln_dx2)
    
    g1 = T(2) * A * dA_dx1 + T(10) * d_cos_term_dx1
    g2 = T(2) * A * dA_dx2 + T(10) * d_cos_term_dx2
    return [g1, g2]
end

const BRANINRCOS2_FUNCTION = TestFunction(
    braninrcos2,
    braninrcos2_gradient,
    Dict(
        :name => "braninrcos2",
        :description => "Branin RCOS Function 2 (Muntenau and Lazarescu, 1998): A multimodal, non-separable test function for nonlinear optimization. Note: Paper reports min=5.559 at [-3.2, 12.53], but computation yields -39.196 at ≈[-3.172, 12.586] – likely paper transcription error; validated via optimization.",
        :math => raw"""f(\mathbf{x}) = \left( x_2 - \frac{5.1 x_1^2}{4\pi^2} + \frac{5 x_1}{\pi} - 6 \right)^2 + 10 \left( 1 - \frac{1}{8\pi} \right) \cos(x_1) \cos(x_2) \ln(x_1^2 + x_2^2 + 1) + 10.""",
        :start => () -> [0.0, 0.0],
        :min_position => () ->  [-3.1721041516027824, 12.58567479697034],
        :min_value => () -> -39.19565391797774,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [15.0, 15.0],
    )
)