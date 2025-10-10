# src/functions/mishra8.jl
# Purpose: Implementation of the Mishra 8 test function.
# Context: Non-scalable, 2D, multimodal function from Mishra (2006f) as compiled in Jamil & Yang (2013).
# Global minimum: f(x*)= 0.0 at x*= [2.0, -3.0].
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: 27. September 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA8_FUNCTION, mishra8, mishra8_gradient

function mishra8(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 8 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    # poly1 coefficients (10th degree)
    g = x1^10 - T(20)*x1^9 + T(180)*x1^8 - T(960)*x1^7 + T(3360)*x1^6 - T(8064)*x1^5 + T(13340)*x1^4 - T(15360)*x1^3 + T(11520)*x1^2 - T(5120)*x1 + T(2624)
    p1 = abs(g)
    # poly2 (4th degree)
    h = x2^4 + T(12)*x2^3 + T(54)*x2^2 + T(108)*x2 + T(81)
    p2 = abs(h)
    T(0.001) * (p1 * p2)^2
end

function mishra8_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Mishra 8 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    # poly1
    g = x1^10 - T(20)*x1^9 + T(180)*x1^8 - T(960)*x1^7 + T(3360)*x1^6 - T(8064)*x1^5 + T(13340)*x1^4 - T(15360)*x1^3 + T(11520)*x1^2 - T(5120)*x1 + T(2624)
    sign_g = sign(g)
    p1 = abs(g)
    dg_dx1 = T(10)*x1^9 - T(180)*x1^8 + T(1440)*x1^7 - T(6720)*x1^6 + T(20160)*x1^5 - T(40320)*x1^4 + T(53360)*x1^3 - T(46080)*x1^2 + T(23040)*x1 - T(5120)
    dp1_dx1 = sign_g * dg_dx1
    # poly2
    h = x2^4 + T(12)*x2^3 + T(54)*x2^2 + T(108)*x2 + T(81)
    sign_h = sign(h)
    p2 = abs(h)
    dh_dx2 = T(4)*x2^3 + T(36)*x2^2 + T(108)*x2 + T(108)
    dp2_dx2 = sign_h * dh_dx2
    
    # f = 0.001 * (p1 p2)^2 → df/dx1 = 0.002 * p1 p2 * (dp1_dx1 p2) = 0.002 p2^2 p1 dp1_dx1 / p1 wait no:
    # Let u = p1 p2, f=0.001 u^2, df/du = 0.002 u, du/dx1 = dp1_dx1 * p2
    # → df/dx1 = 0.002 (p1 p2) * (dp1_dx1 p2) = 0.002 p1 p2^2 dp1_dx1
    grad = zeros(T, 2)
    u = p1 * p2
    grad[1] = T(0.002) * u * (dp1_dx1 * p2)
    grad[2] = T(0.002) * u * (p1 * dp2_dx2)
    grad
end

const MISHRA8_FUNCTION = TestFunction(
    mishra8,
    mishra8_gradient,
    Dict(
        :name => "mishra8",
        :description => "Mishra Function 8 (Decanomial): A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: Corrected coeff. 13340 for x1^4; multiplication between polys.",
        :math => raw"""f(\mathbf{x}) = 0.001 \left[ \left| x_1^{10} - 20 x_1^9 + 180 x_1^8 - 960 x_1^7 + 3360 x_1^6 - 8064 x_1^5 + 13340 x_1^4 - 15360 x_1^3 + 11520 x_1^2 - 5120 x_1 + 2624 \right| \cdot \left| x_2^4 + 12 x_2^3 + 54 x_2^2 + 108 x_2 + 81 \right| \right]^2""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [2.0, -3.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f)",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)