# src/functions/pathological.jl
# Purpose: Implementation of the Pathological test function.
# Context: Scalable multimodal function from Rahnamayan et al. (2007a), as f87 in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=zeros(n).
# Bounds: -100 ≤ x_i ≤ 100.
# Start point: fill(50.0, n)  → NICHT das Minimum!
# Last modified: November 13, 2025.

export PATHOLOGICAL_FUNCTION, pathological, pathological_gradient

function pathological(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Pathological requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    f_val = zero(T)
    @inbounds for i in 1:(n-1)
        xi = x[i]
        xip1 = x[i+1]
        sqrt_term = sqrt(100 * xi^2 + xip1^2)
        sin_sq = sin(sqrt_term)^2
        num = sin_sq - T(0.5)
        den_sq = xi^2 - 2 * xi * xip1 + xip1^2
        den = 1 + 0.001 * den_sq^2
        term = T(0.5) + num / den
        f_val += term
    end
    return f_val
end

function pathological_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Pathological requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:(n-1)
        xi = x[i]
        xip1 = x[i+1]
        sqrt_term = sqrt(100 * xi^2 + xip1^2)
        sin_val = sin(sqrt_term)
        cos_val = cos(sqrt_term)
        sin_sq = sin_val^2
        num = sin_sq - T(0.5)
        den_sq = xi^2 - 2 * xi * xip1 + xip1^2
        den = 1 + 0.001 * den_sq^2
        
        if sqrt_term == zero(T)
            continue  # Gradient zero at origin
        end
        
        # Partial wrt xi
        dsqrt_dxi = (100 * xi) / sqrt_term
        dnum_dxi = 2 * sin_val * cos_val * dsqrt_dxi
        dden_dxi = 0.001 * 2 * den_sq * (2 * xi - 2 * xip1)
        dterm_dxi = (dnum_dxi * den - num * dden_dxi) / den^2
        grad[i] += dterm_dxi
        
        # Partial wrt xip1
        dsqrt_dxip1 = xip1 / sqrt_term
        dnum_dxip1 = 2 * sin_val * cos_val * dsqrt_dxip1
        dden_dxip1 = 0.001 * 2 * den_sq * (-2 * xi + 2 * xip1)
        dterm_dxip1 = (dnum_dxip1 * den - num * dden_dxip1) / den^2
        grad[i+1] += dterm_dxip1
    end
    return grad
end

const PATHOLOGICAL_FUNCTION = TestFunction(
    pathological,
    pathological_gradient,
    Dict(
        :name => "pathological",
        :description => "Pathological Function: Scalable multimodal function with interdependent variables. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n-1} \left( 0.5 + \frac{\sin^2 \sqrt{100 x_i^2 + x_{i+1}^2} - 0.5}{1 + 0.001 (x_i^2 - 2 x_i x_{i+1} + x_{i+1}^2)^2} \right).""",
        :start => (n::Int) -> fill(50.0, n),  # GEÄNDERT: NICHT zeros(n)
        :min_position => (n::Int) -> zeros(n),
        :min_value => (n::Int) -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex", "scalable"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Rahnamayan et al. (2007a), via Jamil & Yang (2013): f87",
        :lb => (n::Int) -> -100 * ones(n),
        :ub => (n::Int) -> 100 * ones(n),
    )
)