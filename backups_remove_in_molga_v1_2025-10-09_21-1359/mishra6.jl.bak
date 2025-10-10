# src/functions/mishra6.jl
# Purpose: Implementation of the Mishra 6 test function.
# Context: Non-scalable, 2D, multimodal function from Mishra (2006) as compiled in Jamil & Yang (2013).
# Global minimum: f(x*)= -2.28394983847 at x*= [2.88630721544, 1.82326033142].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: 27. September 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA6_FUNCTION, mishra6, mishra6_gradient

function mishra6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    c1 = cos(x1) + cos(x2)
    s1 = sin(x1) + sin(x2)
    f1 = sin(c1^2)^2
    f2 = cos(s1^2)^2
    inner = f1 - f2 + x1
    f3 = T(0.1) * ((x1 - 1)^2 + (x2 - 1)^2)
    -log(inner^2) + f3
end

function mishra6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 6 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    c1 = cos(x1) + cos(x2)
    s1 = sin(x1) + sin(x2)
    u = c1^2
    v = s1^2
    f1 = sin(u)^2
    f2 = cos(v)^2
    inner = f1 - f2 + x1
    
    # Partial derivatives for inner
    du_dx1 = 2 * c1 * (-sin(x1))
    dv_dx1 = 2 * s1 * cos(x1)
    df1_dx1 = 2 * sin(u) * cos(u) * du_dx1
    df2_dx1 = 2 * cos(v) * (-sin(v)) * dv_dx1
    d_inner_dx1 = df1_dx1 - df2_dx1 + 1
    
    du_dx2 = 2 * c1 * (-sin(x2))
    dv_dx2 = 2 * s1 * cos(x2)
    df1_dx2 = 2 * sin(u) * cos(u) * du_dx2
    df2_dx2 = 2 * cos(v) * (-sin(v)) * dv_dx2
    d_inner_dx2 = df1_dx2 - df2_dx2
    
    # Gradient: -2 * (d_inner/dx) / inner + 0.2 * (xi - 1)
    grad = zeros(T, 2)
    grad[1] = -T(2) / inner * d_inner_dx1 + T(0.2) * (x1 - 1)
    grad[2] = -T(2) / inner * d_inner_dx2 + T(0.2) * (x2 - 1)
    grad
end

const MISHRA6_FUNCTION = TestFunction(
    mishra6,
    mishra6_gradient,
    Dict(
        :name => "mishra6",
        :description => "Mishra Function 6: A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: f3 term outside log; coeff. 0.1 (Jamil lists 0.01, likely typo).",
        :math => raw"""f(\mathbf{x}) = -\ln \left[ \left( \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) - \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right)^2 \right] + 0.1 \left( (x_1 - 1)^2 + (x_2 - 1)^2 \right)""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [2.88630721544, 1.82326033142],
        :min_value => () -> -2.28394983847,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)