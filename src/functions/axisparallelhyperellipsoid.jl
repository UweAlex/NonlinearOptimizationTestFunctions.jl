# src/functions/axisparallelhyperellipsoid.jl
# Purpose: Implementation of the Axis Parallel Hyper-Ellipsoid test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n).
# Bounds: -5.12 ≤ x_i ≤ 5.12.

export AXISPARALLELHYPERELLIPSOID_FUNCTION, axisparallelhyperellipsoid, axisparallelhyperellipsoid_gradient

function axisparallelhyperellipsoid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    sum(i * x[i]^2 for i in 1:n)
end

function axisparallelhyperellipsoid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 2 * i * x[i]
    end
    grad
end

const AXISPARALLELHYPERELLIPSOID_FUNCTION = TestFunction(
    axisparallelhyperellipsoid,
    axisparallelhyperellipsoid_gradient,
    Dict{Symbol, Any}(
        :name => "axisparallelhyperellipsoid",
        :description => "Properties based on Jamil & Yang (2013, p. 4); Convex, quadratic function.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n i x_i^2.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension")); fill(1.0, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["convex", "differentiable", "separable", "scalable", "continuous"],
        :source => "Jamil & Yang (2013, p. 4)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension")); fill(-5.12, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("axisparallelhyperellipsoid requires at least 1 dimension")); fill(5.12, n) end,
    )
)

# Optional: Validierung beim Laden
