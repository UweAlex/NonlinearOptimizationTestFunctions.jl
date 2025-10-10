# src/functions/penholder.jl
# Purpose: Implementation of the Pen Holder test function.
# Context: Non-scalable, 2D multimodal function from Mishra (2006f), as f86 in Jamil & Yang (2013).
# Global minimum: f(x*)=-0.9635348327265058 at x*=[±9.646167671043401, ±9.646167671043401] (four points).
# Bounds: -11 ≤ x_i ≤ 11.
# Last modified: September 29, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export PENHOLDER_FUNCTION, penholder, penholder_gradient

function penholder(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Pen Holder requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    r = sqrt(x1^2 + x2^2)
    if r == zero(T)
        return -one(T)  # Limit as r->0
    end
    alpha = abs(one(T) - r / T(π))
    exp_alpha = exp(alpha)
    cos_prod = cos(x1) * cos(x2) * exp_alpha
    h = abs(cos_prod)
    if h == zero(T)
        return zero(T)
    end
    return -exp(-one(T) / h)
end

function penholder_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Pen Holder requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    r = sqrt(x1^2 + x2^2)
    if r == zero(T)
        return zeros(T, 2)
    end
    alpha = abs(one(T) - r / T(π))
    exp_alpha = exp(alpha)
    cos1 = cos(x1)
    cos2 = cos(x2)
    g = cos1 * cos2 * exp_alpha
    h = abs(g)
    if h == zero(T)
        return fill(T(NaN), 2)
    end
    
    s_g = sign(g)
    dr_dx1 = x1 / r
    dalpha_dx1 = sign(one(T) - r / T(π)) * (-dr_dx1 / T(π))
    dexp_dx1 = exp_alpha * dalpha_dx1
    dg_dx1 = -sin(x1) * cos2 * exp_alpha + cos1 * cos2 * dexp_dx1
    
    dr_dx2 = x2 / r
    dalpha_dx2 = sign(one(T) - r / T(π)) * (-dr_dx2 / T(π))
    dexp_dx2 = exp_alpha * dalpha_dx2
    dg_dx2 = cos1 * -sin(x2) * exp_alpha + cos1 * cos2 * dexp_dx2
    
    dh_dx1 = s_g * dg_dx1
    dh_dx2 = s_g * dg_dx2
    
    common = exp(-one(T) / h) * (one(T) / h^2)
    grad1 = - common * dh_dx1  # Fixed: Added negative sign for df/dh
    grad2 = - common * dh_dx2  # Fixed: Added negative sign for df/dh
    
    return [grad1, grad2]
end

const PENHOLDER_FUNCTION = TestFunction(
    penholder,
    penholder_gradient,
    Dict(
        :name => "penholder",
        :description => "Pen Holder Function: 2D multimodal function with four global minima. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = -\exp\left( -\frac{1}{\left| \cos(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|} \right).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [9.646167671043401, 9.646167671043401],
        :min_value => () -> -0.9635348327265058,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f), via Jamil & Yang (2013): f86",
        :lb => () -> [-11.0, -11.0],
        :ub => () -> [11.0, 11.0]
    )
)