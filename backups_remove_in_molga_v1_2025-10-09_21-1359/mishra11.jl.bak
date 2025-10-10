# src/functions/mishra11.jl
# Purpose: Implementation of the Mishra Function 11 test function (AMGM Function).
# Context: Scalable, multimodal function from Mishra (2006f), as f84 in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[1,1,...,1] (and other points where all |x_i| equal).
# Bounds: 0 ≤ x_i ≤ 10.
# Last modified: September 29, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export MISHRA11_FUNCTION, mishra11, mishra11_gradient

function mishra11(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra 11 requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    a = abs.(x)
    if any(a .== zero(T))
        return zero(T)  # Prod=0, but AM >=0, f=AM^2
    end
    
    am = sum(a) / n
    gm = prod(a)^(one(T)/n)
    return (am - gm)^2
end

function mishra11_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Mishra 11 requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    a = abs.(x)
    if any(a .== zero(T))
        return zeros(T, n)  # Subgradient at zero
    end
    
    am = sum(a) / n
    gm = prod(a)^(one(T)/n)
    diff = am - gm
    
    grad = zeros(T, n)
    @inbounds for j in 1:n
        s_j = sign(x[j])
        du = one(T) / n * s_j
        dv = (one(T) / n) * (gm / a[j]) * s_j
        grad[j] = 2 * diff * (du - dv)
    end
    return grad
end

const MISHRA11_FUNCTION = TestFunction(
    mishra11,
    mishra11_gradient,
    Dict(
        :name => "mishra11",
        :description => "Mishra Function 11 (AMGM): Scalable multimodal function based on arithmetic-geometric mean inequality. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \left[ \frac{1}{n} \sum_{i=1}^n |x_i| - \left( \prod_{i=1}^n |x_i| \right)^{1/n} \right]^2.""",
        :start => (n::Int) -> 0.5 * ones(n),
        :min_position => (n::Int) -> ones(n),
        :min_value => (n::Int) -> 0.0,  # Fix: Akzeptiert n (konstant, ignoriert es)
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex", "scalable"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Mishra (2006f), via Jamil & Yang (2013): f84",
        :lb => (n::Int) -> zeros(n),
        :ub => (n::Int) -> 10 * ones(n),
    )
)
