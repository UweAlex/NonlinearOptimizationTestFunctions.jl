# src/functions/schaffer1.jl
# Purpose: Implementation of the Schaffer's Function No. 01.
# Global minimum: f(x*)=0.0 at x*=(0.0, 0.0).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHAFFER1_FUNCTION, schaffer1, schaffer1_gradient

function schaffer1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffer1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    r_sq = x[1]^2 + x[2]^2
    numerator = sin(r_sq)^2 - 0.5
    denominator = (1.0 + 0.001 * r_sq)^2
    
    return 0.5 + numerator / denominator
end

function schaffer1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("schaffer1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    r_sq = x[1]^2 + x[2]^2
    num = sin(r_sq)^2 - 0.5
    den_base = 1.0 + 0.001 * r_sq
    den = den_base^2
    
    dnum_drsq = sin(2 * r_sq)
    dden_drsq = 2.0 * den_base * 0.001
    df_drsq = (dnum_drsq * den - num * dden_drsq) / den^2
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = df_drsq * 2.0 * x[i]
    end
    
    return grad
end

const SCHAFFER1_FUNCTION = TestFunction(
    schaffer1,
    schaffer1_gradient,
    Dict(
        :name => "schaffer1",
        :description => "Schaffer's Function No. 01. Highly multimodal with concentric rings of local minima caused by the squared sine term. The function is non-separable due to coupling through x₁² + x₂².",
        :math => raw"""f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 + x_2^2) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 136, Function 112)",
        :lb => () -> fill(-100.0, 2),
        :ub => () -> fill(100.0, 2),
    )
)
