# src/functions/holder_table1.jl
# Purpose: Implementation of the Holder Table 1 test function.
# Global minimum: f(x*)=-19.208502 at x*=(8.0550238, -9.6643736) (one of four global minima).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export HOLDER_TABLE1_FUNCTION, holder_table1, holder_table1_gradient

function holder_table1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("holder_table1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    g = sin(x1) * cos(x2) * exp(abs(1 - r / π))
    -abs(g)
end

function holder_table1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("holder_table1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    if r == 0
        return zeros(T, 2)
    end
    a = 1 - r / π
    sign_a = a > 0 ? one(T) : (a < 0 ? -one(T) : zero(T))
    exp_h = exp(abs(a))
    g = sin(x1) * cos(x2) * exp_h
    if g == 0
        return zeros(T, 2)
    end
    sign_g = g > 0 ? one(T) : -one(T)
    
    dr_dx1 = x1 / r
    dr_dx2 = x2 / r
    dh_dx1 = sign_a * (-1 / π) * dr_dx1
    dh_dx2 = sign_a * (-1 / π) * dr_dx2
    
    dg_dx1 = cos(x1) * cos(x2) * exp_h + g * dh_dx1
    dg_dx2 = -sin(x1) * sin(x2) * exp_h + g * dh_dx2
    
    grad = [-sign_g * dg_dx1, -sign_g * dg_dx2]
    grad
end

const HOLDER_TABLE1_FUNCTION = TestFunction(
    holder_table1,
    holder_table1_gradient,
    Dict(
        :name => "holder_table1",
        :description => "Properties based on Jamil & Yang (2013, p. 34); four global minima; adapted formula from Surjano for consistency (sin/cos and abs in exp); originally from Mishra (2006). Non-separable due to interactions despite source claim.",
        :math => raw"""f(\mathbf{x}) = -\left| \sin(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [8.05502347573655, -9.664590019241274],
        :min_value => () -> -19.208502567886743,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 34)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
