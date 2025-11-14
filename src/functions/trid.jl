# src/functions/trid.jl
# Purpose: Implementation of the Trid test function.
# Global minimum: f(x*)=-n*(n+4)*(n-1)/6 at x*=[i*(n+1 - i) for i=1:n].
# Bounds: -n^2 ≤ x_i ≤ n^2.

export TRID_FUNCTION, trid, trid_gradient

function trid(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("trid requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum1 = sum((x[i] - 1)^2 for i in 1:n)
    sum2 = sum(x[i] * x[i-1] for i in 2:n)
    sum1 - sum2
end

function trid_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("trid requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    grad[1] = 2 * (x[1] - 1) - x[2]
    @inbounds for i in 2:n-1
        grad[i] = 2 * (x[i] - 1) - x[i-1] - x[i+1]
    end
    grad[n] = 2 * (x[n] - 1) - x[n-1]
    grad
end

const TRID_FUNCTION = TestFunction(
    trid,
    trid_gradient,
    Dict{Symbol, Any}(
        :name => "trid",
        :description => "Trid function; Properties based on Jamil & Yang (2013, p. 35); Adapted for scalable unimodal variant; ursprünglich aus Dixon & Szegö (1978).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n (x_i - 1)^2 - \sum_{i=2}^n x_i x_{i-1}.""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); [i * (n + 1 - i) for i in 1:n] end,
        :min_value => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); -n * (n + 4) * (n - 1) / 6 end,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "unimodal", "convex", "bounded"],
        :source => "Jamil & Yang (2013, p. 35)",
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); fill(-n^2, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("trid requires at least 2 dimensions")); fill(n^2, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "trid" == basename(@__FILE__)[1:end-3] "trid: Dateiname mismatch!"