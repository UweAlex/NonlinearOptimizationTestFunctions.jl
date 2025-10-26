# src/functions/holder_table2.jl
# Purpose: Implementation of the Holder Table 2 test function.
# Global minimum: f(x*)=-11.6839 at x*=(8.051, -10.0) (one of four global minima, adapted from optimization due to source discrepancy).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export HOLDER_TABLE2_FUNCTION, holder_table2, holder_table2_gradient

function holder_table2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("holder_table2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    r = sqrt(x1^2 + x2^2)
    g = sin(x1) * sin(x2) * exp(abs(1 - r / π))
    -abs(g)
end

function holder_table2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("holder_table2 requires exactly 2 dimensions"))
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
    g = sin(x1) * sin(x2) * exp_h
    if g == 0
        return zeros(T, 2)
    end
    sign_g = g > 0 ? one(T) : -one(T)
    
    dr_dx1 = x1 / r
    dr_dx2 = x2 / r
    dh_dx1 = sign_a * (-1 / π) * dr_dx1
    dh_dx2 = sign_a * (-1 / π) * dr_dx2
    
    dg_dx1 = cos(x1) * sin(x2) * exp_h + g * dh_dx1
    dg_dx2 = sin(x1) * cos(x2) * exp_h + g * dh_dx2
    
    grad = [-sign_g * dg_dx1, -sign_g * dg_dx2]
    grad
end

const HOLDER_TABLE2_FUNCTION = TestFunction(
    holder_table2,
    holder_table2_gradient,
    Dict(
        :name => "holder_table2",
        :description => "Properties based on Jamil & Yang (2013, p. 34); four global minima; adapted formula from Surjano/Al-Roomi for consistency (sin/sin and Euclidean norm in exp); source minimum -19.2085 not matching formula (computed -11.6839); originally from Mishra (2006). Non-separable due to interactions.",
        :math => raw"""f(\mathbf{x}) = -\left| \sin(x_1) \sin(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.""",
        :start => () -> [0.0, 0.0],
   :min_position => () -> [8.051008722128277, -9.999999999999],
  :min_value => () -> -11.683926748430029,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 34)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)

# Optional: Validierung beim Laden
@assert "holder_table2" == basename(@__FILE__)[1:end-3] "holder_table2: Dateiname mismatch!"