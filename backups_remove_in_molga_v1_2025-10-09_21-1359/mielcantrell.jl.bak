# src/functions/mielcantrell.jl
# Purpose: Implementation of the Miele-Cantrell test function.
# Context: Non-scalable (n=4), continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*)=0 at x*=[0,1,1,1].
# Bounds: -1 ≤ x_i ≤ 1.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MIELCANTRELL_FUNCTION, mielcantrell, mielcantrell_gradient

function mielcantrell(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Miele-Cantrell requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3, x4 = x[1], x[2], x[3], x[4]
    (exp(x1) - x2)^4 + 100 * (x2 - x3)^6 + tan(x3 - x4)^4 + x1^8
end

function mielcantrell_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("Miele-Cantrell requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 4)
    any(isinf.(x)) && return fill(T(Inf), 4)
    
    x1, x2, x3, x4 = x[1], x[2], x[3], x[4]
    grad = zeros(T, 4)
    term1 = exp(x1) - x2
    term2 = x2 - x3
    term3 = tan(x3 - x4)
    sec_sq = sec(x3 - x4)^2
    grad[1] = 4 * term1^3 * exp(x1) + 8 * x1^7
    grad[2] = -4 * term1^3 + 600 * term2^5
    grad[3] = -600 * term2^5 + 4 * term3^3 * sec_sq
    grad[4] = -4 * term3^3 * sec_sq
    grad
end

const MIELCANTRELL_FUNCTION = TestFunction(
    mielcantrell,
    mielcantrell_gradient,
    Dict(
        :name => "mielcantrell",
        :description => "The Miele-Cantrell function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = (e^{x_1} - x_2)^4 + 100 (x_2 - x_3)^6 + [\tan(x_3 - x_4)]^4 + x_1^8 """,
        :start => () -> [0.0, 0.0, 0.0, 0.0],
        :min_position => () -> [0.0, 1.0, 1.0, 1.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Cragg and Levy (1969)",
        :lb => () -> [-1.0, -1.0, -1.0, -1.0],
        :ub => () -> [1.0, 1.0, 1.0, 1.0],
    )
)