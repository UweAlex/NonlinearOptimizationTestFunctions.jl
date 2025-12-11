# src/functions/mishra9.jl
# Purpose: Implementation of the Mishra 9 test function.
# Context: Non-scalable, 3D, multimodal function from Mishra (2006f) as compiled in Jamil & Yang (2013).
# Global minimum: f(x*)= 0.0 at x*= [1.0, 2.0, 3.0].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: 28. November 2025.
# Fix: dc_dx3 korrigiert - der Term T(6)*x3 war falsch.

export MISHRA9_FUNCTION, mishra9, mishra9_gradient

function mishra9(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Mishra 9 requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3 = x[1], x[2], x[3]
    a = T(2)*x1^3 + T(5)*x1*x2 + T(4)*x3 - T(2)*x1^2*x3 - T(18)
    b = x1 + x2^3 + x1*x2^2 + x1*x3^2 - T(22)
    c = T(8)*x1^2 + T(2)*x2*x3 + T(2)*x2^2 + T(3)*x2^3 - T(52)
    term1 = a * b^2 * c
    term2 = a * b * c^2
    term3 = b^2
    term4 = (x1 + x2 - x3)^2
    inner = term1 + term2 + term3 + term4
    inner^2
end

function mishra9_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Mishra 9 requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)
    
    x1, x2, x3 = x[1], x[2], x[3]
    a = T(2)*x1^3 + T(5)*x1*x2 + T(4)*x3 - T(2)*x1^2*x3 - T(18)
    b = x1 + x2^3 + x1*x2^2 + x1*x3^2 - T(22)
    c = T(8)*x1^2 + T(2)*x2*x3 + T(2)*x2^2 + T(3)*x2^3 - T(52)
    term1 = a * b^2 * c
    term2 = a * b * c^2
    term3 = b^2
    term4 = (x1 + x2 - x3)^2
    inner = term1 + term2 + term3 + term4
    
    # Partials for a, b, c
    da_dx1 = T(6)*x1^2 + T(5)*x2 - T(4)*x1*x3
    da_dx2 = T(5)*x1
    da_dx3 = T(4) - T(2)*x1^2
    
    db_dx1 = T(1) + x2^2 + x3^2
    db_dx2 = T(3)*x2^2 + T(2)*x1*x2
    db_dx3 = T(2)*x1*x3
    
    dc_dx1 = T(16)*x1
    dc_dx2 = T(2)*x3 + T(4)*x2 + T(9)*x2^2
    dc_dx3 = T(2)*x2  # KORREKTUR: + T(6)*x3 entfernt
    
    # d(term1)/dx = da*b^2*c + a*2b*db*c + a*b^2*dc
    dterm1_dx1 = da_dx1 * b^2 * c + a * T(2)*b * db_dx1 * c + a * b^2 * dc_dx1
    dterm1_dx2 = da_dx2 * b^2 * c + a * T(2)*b * db_dx2 * c + a * b^2 * dc_dx2
    dterm1_dx3 = da_dx3 * b^2 * c + a * T(2)*b * db_dx3 * c + a * b^2 * dc_dx3
    
    # d(term2)/dx = da*b*c^2 + a*db*c^2 + a*b*2c*dc
    dterm2_dx1 = da_dx1 * b * c^2 + a * db_dx1 * c^2 + a * b * T(2)*c * dc_dx1
    dterm2_dx2 = da_dx2 * b * c^2 + a * db_dx2 * c^2 + a * b * T(2)*c * dc_dx2
    dterm2_dx3 = da_dx3 * b * c^2 + a * db_dx3 * c^2 + a * b * T(2)*c * dc_dx3
    
    # d(term3)/dx = 2*b*db
    dterm3_dx1 = T(2) * b * db_dx1
    dterm3_dx2 = T(2) * b * db_dx2
    dterm3_dx3 = T(2) * b * db_dx3
    
    # d(term4)/dx = 2*(x1+x2-x3) * d(x1+x2-x3)/dx
    s = x1 + x2 - x3
    dterm4_dx1 = T(2) * s * T(1)
    dterm4_dx2 = T(2) * s * T(1)
    dterm4_dx3 = T(2) * s * (-T(1))
    
    # d(inner)/dx = sum of d(term)/dx
    d_inner_dx1 = dterm1_dx1 + dterm2_dx1 + dterm3_dx1 + dterm4_dx1
    d_inner_dx2 = dterm1_dx2 + dterm2_dx2 + dterm3_dx2 + dterm4_dx2
    d_inner_dx3 = dterm1_dx3 + dterm2_dx3 + dterm3_dx3 + dterm4_dx3
    
    # grad = 2 * inner * d(inner)/dx
    grad = zeros(T, 3)
    grad[1] = T(2) * inner * d_inner_dx1
    grad[2] = T(2) * inner * d_inner_dx2
    grad[3] = T(2) * inner * d_inner_dx3
    grad
end

const MISHRA9_FUNCTION = TestFunction(
    mishra9,
    mishra9_gradient,
    Dict(
        :name => "mishra9",
        :description => "Mishra Function 9 (Dodecal Polynomial): A 3D multimodal test function. Properties based on Jamil & Yang (2013). Corrected terms in b and c from al-roomi.org for f(1,2,3)=0.",
        :math => raw"""f(\mathbf{x}) = \left[ f_1 f_2^2 f_3 + f_1 f_2 f_3^2 + f_2^2 + (x_1 + x_2 - x_3)^2 \right]^2 \\ where \\ f_1 = 2x_1^3 + 5x_1 x_2 + 4x_3 - 2x_1^2 x_3 - 18, \\ f_2 = x_1 + x_2^3 + x_1 x_2^2 + x_1 x_3^2 - 22, \\ f_3 = 8x_1^2 + 2x_2 x_3 + 2x_2^2 + 3x_2^3 - 52.""",
        :start => () -> [0.0, 0.0, 0.0],
        :min_position => () -> [1.0, 2.0, 3.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f)",
        :lb => () -> [-10.0, -10.0, -10.0],
        :ub => () -> [10.0, 10.0, 10.0],
    )
)