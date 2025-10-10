# src/functions/schaffer6.jl
# Purpose: Implementation of the Schaffer's Function No. 06.
# Global minimum: f(x*)=0.0 at x*=(0.0, 0.0).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHAFFER6_FUNCTION, schaffer6, schaffer6_gradient

function schaffer6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return 0.5
    
    r_sq = x[1]^2 + x[2]^2
    
    numerator = sin(sqrt(r_sq))^2 - 0.5
    denominator = (1 + 0.001 * r_sq)^2
    
    return 0.5 + numerator / denominator
end

function schaffer6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("$(func_name) requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return zeros(T, n)
    
    x1, x2 = x[1], x[2]
    r_sq = x1^2 + x2^2
    
    if r_sq == 0
        return zeros(T, n)
    end
    
    r = sqrt(r_sq)
    common_term_denom = (1 + 0.001 * r_sq)^3
    
    term1 = (sin(2*r) / r) * (1 + 0.001 * r_sq)
    term2 = 0.004 * (sin(r)^2 - 0.5)
    
    common_multiplier = (term1 - term2) / common_term_denom
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = x[i] * common_multiplier
    end
    
    return grad
end

const SCHAFFER6_FUNCTION = TestFunction(
    schaffer6,
    schaffer6_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :description => "Schaffer's Function No. 06. Continuous, single-objective benchmark function for unconstrained global optimization in 2D. Highly multimodal with concentric rings of local minima due to the oscillatory sine term applied to the radius. The function is non-separable due to coupling through x₁² + x₂².",
        :math => raw"""f(\mathbf{x}) = 0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :source => "Al-Roomi (2015, Schaffer's Function No. 06)",
        :lb => () -> fill(-100.0, 2),
        :ub => () -> fill(100.0, 2),
    )
)