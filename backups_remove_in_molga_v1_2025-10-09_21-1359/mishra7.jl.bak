# src/functions/mishra7.jl
# Purpose: Implementation of the Mishra 7 test function.
# Context: Non-scalable, 2D, multimodal function from Mishra (2006f) as compiled in Jamil & Yang (2013).
# Global minimum: f(x*)= 0.0 at x*= [1.0, 2.0] (one of many where prod(x) = 2).
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: 27. September 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA7_FUNCTION, mishra7, mishra7_gradient

function mishra7(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 7 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    prod_term = x1 * x2
    inner = prod_term - T(2)  # 2! = 2
    inner^2
end

function mishra7_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 7 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    prod_term = x1 * x2
    inner = prod_term - T(2)
    
    # Partial derivatives: 2 * inner * (x2 for dx1, x1 for dx2)
    grad = zeros(T, 2)
    grad[1] = T(2) * inner * x2
    grad[2] = T(2) * inner * x1
    grad
end

const MISHRA7_FUNCTION = TestFunction(
    mishra7,
    mishra7_gradient,
    Dict(
        :name => "mishra7",
        :description => "Mishra Function 7: A 2D multimodal test function with multiple global minima where prod(x) = 2. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left[ x_1 x_2 - 2! \right]^2""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [1.0, 2.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)