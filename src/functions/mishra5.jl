# src/functions/mishra5.jl
# Purpose: Implementation of the Mishra 5 test function.
# Context: Non-scalable, 2D, multimodal function from Mishra (2006f) as compiled in Jamil & Yang (2013).
# Global minimum: f(x*)= -0.11982951993 at x*= [-1.98682, -10].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: 27. September 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA5_FUNCTION, mishra5, mishra5_gradient

function mishra5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 5 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    c1 = cos(x1) + cos(x2)
    s1 = sin(x1) + sin(x2)
    a = sin(c1^2)^2
    b = cos(s1^2)^2
    inner = a + b + x1
    inner^2 + 0.01*(x1 + x2)
end

function mishra5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 5 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    c1 = cos(x1) + cos(x2)
    s1 = sin(x1) + sin(x2)
    a = sin(c1^2)^2
    b = cos(s1^2)^2
    inner = a + b + x1
    
    # Partial derivatives (analytical)
    da_dx1 = 2 * sin(c1^2) * cos(c1^2) * 2 * c1 * (-sin(x1))
    da_dx2 = 2 * sin(c1^2) * cos(c1^2) * 2 * c1 * (-sin(x2))
    db_dx1 = 2 * cos(s1^2) * (-sin(s1^2)) * 2 * s1 * cos(x1)
    db_dx2 = 2 * cos(s1^2) * (-sin(s1^2)) * 2 * s1 * cos(x2)
    
    d_inner_dx1 = da_dx1 + db_dx1 + 1
    d_inner_dx2 = da_dx2 + db_dx2
    
    grad = zeros(T, 2)
    grad[1] = 2 * inner * d_inner_dx1 + 0.01
    grad[2] = 2 * inner * d_inner_dx2 + 0.01
    grad
end

const MISHRA5_FUNCTION = TestFunction(
    mishra5,
    mishra5_gradient,
    Dict(
        :name => "mishra5",
        :description => "Mishra Function 5: A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: PDF reports erroneous min position; validated via optimization.",
        :math => raw"""f(\mathbf{x}) = \left[ \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) + \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right]^2 + 0.01(x_1 + x_2)""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-1.98682, -10.0],
        :min_value => () -> -0.11982951993,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)