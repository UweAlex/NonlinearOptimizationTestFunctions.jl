# src/functions/schwefel12.jl
# Purpose: Implementation of the Schwefel 1.2 test function.
# Global minimum: f(x*)=0.0 at x*=(0.0, ..., 0.0).
# Bounds: -100.0 ≤ x_i ≤ 100.0.
# Start point: fill(50.0, n) → NICHT das Minimum!
# Last modified: November 13, 2025.

export SCHWEFEL12_FUNCTION, schwefel12, schwefel12_gradient

function schwefel12(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    sum_sq = zero(T)
    prefix = zero(T)
    @inbounds for i in 1:n
        prefix += x[i]
        sum_sq += prefix^2
    end
    sum_sq
end

function schwefel12_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    s = zeros(T, n)
    prefix = zero(T)
    @inbounds for i in 1:n
        prefix += x[i]
        s[i] = prefix
    end
    
    grad = zeros(T, n)
    @inbounds grad[n] = 2 * s[n]
    @inbounds for i in n-1:-1:1
        grad[i] = grad[i+1] + 2 * s[i]
    end
    grad
end

const SCHWEFEL12_FUNCTION = TestFunction(
    schwefel12,
    schwefel12_gradient,
    Dict{Symbol, Any}(
        :name => "schwefel12",
        :description => "Schwefel 1.2 function; also known as Rotated Hyper-Ellipsoid or Double-Sum Function. Properties based on Jamil & Yang (2013, p. 29); originally from Schwefel (1977).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n \left( \sum_{j=1}^i x_j \right)^2.""",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
            fill(50.0, n)  # GEÄNDERT: NICHT das Minimum
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
            zeros(n)
        end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["bounded", "continuous", "convex", "differentiable", "non-separable", "scalable", "unimodal"],
        :source => "Jamil & Yang (2013, p. 29)",
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
            fill(-100.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("schwefel12 requires at least 1 dimension"))
            fill(100.0, n)
        end,
    )
)

# Validierung beim Laden
@assert basename(@__FILE__)[1:end-3] == "schwefel12" "schwefel12: Dateiname mismatch!"