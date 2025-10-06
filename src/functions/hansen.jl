# src/functions/hansen.jl
# Purpose: Implementation of the Hansen test function.
# Context: Non-scalable, 2D, from Jamil & Yang (2013), function 61.
# Global minimum: f(x*)=-176.541793 at x*=[-7.589893, -7.708314] (one of multiple).
# Bounds: -10 <= x_i <= 10.
# Last modified: September 26, 2025.
# Properties based on Jamil & Yang (2013).

export HANSEN_FUNCTION, hansen, hansen_gradient

function hansen(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Hansen requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    
    s1 = zero(T)
    @inbounds for i in 0:4
        s1 += (i + one(T)) * cos(i * x1 + i + one(T))
    end
    
    s2 = zero(T)
    @inbounds for j in 0:4
        s2 += (j + one(T)) * cos((j + T(2)) * x2 + j + one(T))
    end
    
    s1 * s2
end

function hansen_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Hansen requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    
    s1 = zero(T)
    ds1 = zero(T)
    one_t = one(T)
    @inbounds for i in 0:4
        arg = i * x1 + i + one_t
        ci = cos(arg)
        si = sin(arg)
        s1 += (i + one_t) * ci
        ds1 -= (i + one_t) * si * i
    end
    
    s2 = zero(T)
    ds2 = zero(T)
    @inbounds for j in 0:4
        arg = (j + T(2)) * x2 + j + one_t
        cj = cos(arg)
        sj = sin(arg)
        s2 += (j + one_t) * cj
        ds2 -= (j + one_t) * sj * (j + T(2))
    end
    
    grad = zeros(T, 2)
    grad[1] = ds1 * s2
    grad[2] = s1 * ds2
    grad
end

const HANSEN_FUNCTION = TestFunction(
    hansen,
    hansen_gradient,
    Dict(
        :name => "hansen",
        :description => "The Hansen function, a 2D multimodal separable function with multiple global minima. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=0}^{4} (i+1)\cos(i x_1 + i+1) \sum_{j=0}^{4} (j+1)\cos((j+2) x_2 + j+1).""",
        :start => () -> [0.0, 0.0],
  :min_position => () -> [-7.5898930108008882, -7.7083137354993481],
  :min_value => () -> -176.5417931367457,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)