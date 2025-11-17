# src/functions/alpinen1.jl
# Purpose: Implementation of the AlpineN1 test function.
# Global minimum: f(x*)=0.0 at x* = zeros(n) and other points where x_i sin(x_i) + 0.1 x_i = 0.
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export ALPINEN1_FUNCTION, alpinen1, alpinen1_gradient

function alpinen1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    sum(abs(xi * sin(xi) + 0.1 * xi) for xi in x)
end

function alpinen1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    non_diff = false
    for i in 1:n
        xi = x[i]
        term = xi * sin(xi) + 0.1 * xi
        if isapprox(term, 0, atol=1e-10)
            non_diff = true
            break
        end
        grad[i] = sign(term) * (sin(xi) + xi * cos(xi) + 0.1)
    end
    if non_diff
        return fill(T(NaN), n)
    end
    grad
end

const ALPINEN1_FUNCTION = TestFunction(
    alpinen1,
    alpinen1_gradient,
    Dict{Symbol, Any}(
        :name => "alpinen1",
        :description => "Properties based on Jamil & Yang (2013, p. 5); Contains absolute value terms leading to non-differentiability at certain points (gradient returns NaN there).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n |x_i \sin x_i + 0.1 x_i|.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension")); fill(1.0, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["multimodal", "non-convex", "separable", "partially differentiable", "scalable", "bounded"],
        :source => "Jamil & Yang (2013, p. 5)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen1 requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "alpinen1" == basename(@__FILE__)[1:end-3] "alpinen1: Dateiname mismatch!"