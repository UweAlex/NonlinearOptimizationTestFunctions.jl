# src/functions/paviani.jl
# Purpose: Implementation of the Paviani test function.
# Context: Non-scalable, 10D multimodal function from Himmelblau (1972), as f88 in Jamil & Yang (2013).
# Global minimum: f(x* )≈ -45.7784684040686 at x* ≈[9.350266, ..., 9.350266].
# Bounds: 2.001 ≤ x_i ≤ 9.999.
# Last modified: September 29, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export PAVIANI_FUNCTION, paviani, paviani_gradient

function paviani(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 10 && throw(ArgumentError("Paviani requires exactly 10 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Clamp to domain for robustness in edge cases
    x_clamped = clamp.(x, T(2.001), T(9.999))
    
    sum_term = zero(T)
    @inbounds for i in 1:10
        ln1 = log(x_clamped[i] - T(2))
        ln2 = log(T(10) - x_clamped[i])
        sum_term += ln1^2 + ln2^2
    end
    
    prod_term = prod(x_clamped)
    if prod_term <= zero(T)
        return T(Inf)
    end
    
    return sum_term - prod_term^(T(0.2))
end

function paviani_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 10 && throw(ArgumentError("Paviani requires exactly 10 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 10)
    any(isinf.(x)) && return fill(T(Inf), 10)
    
    # Clamp to domain for robustness
    x_clamped = clamp.(x, T(2.001), T(9.999))
    
    prod_term = prod(x_clamped)
    if prod_term <= zero(T)
        return fill(T(Inf), 10)
    end
    
    p_pow = prod_term^(T(0.2))
    p_inv = prod_term^(-T(0.8))
    
    grad = zeros(T, 10)
    @inbounds for j in 1:10
        ln1 = log(x_clamped[j] - T(2))
        ln2 = log(T(10) - x_clamped[j])
        local_term = T(2) * ln1 / (x_clamped[j] - T(2)) - T(2) * ln2 / (T(10) - x_clamped[j])
        prod_deriv = - T(0.2) * p_inv * (prod_term / x_clamped[j])
        grad[j] = local_term + prod_deriv
    end
    return grad
end

const PAVIANI_FUNCTION = TestFunction(
    paviani,
    paviani_gradient,
    Dict(
        :name => "paviani",
        :description => "Paviani Function: 10D multimodal function involving logs and product. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{10} \left[ \left(\ln (x_i - 2)\right)^2 + \left(\ln (10 - x_i)\right)^2 \right] - \left( \prod_{i=1}^{10} x_i \right)^{0.2}. """,
        :start => () -> fill(5.0, 10),
      :min_position => () -> fill(9.350265833069052, 10),  # war: 9.350266
:min_value => () -> -45.77846970744629,  # Präziser
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Himmelblau (1972), via Jamil & Yang (2013): f88",
        :lb => () -> fill(2.001, 10),
        :ub => () -> fill(9.999, 10)
    )
)