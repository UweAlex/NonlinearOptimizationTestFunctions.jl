# src/functions/qing.jl
# Purpose: Implementation of the Qing test function.
# Global minimum: f(x*)=0.0 at x*=±sqrt.(1:n) (any sign combination).
# Bounds: -500.0 ≤ x_i ≤ 500.0.

export QING_FUNCTION, qing, qing_gradient

function qing(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        diff = x[i]^2 - i
        sum_sq += diff^2
    end
    sum_sq
end

function qing_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        diff = x[i]^2 - i
        grad[i] = 4 * x[i] * diff
    end
    grad
end

const QING_FUNCTION = TestFunction(
    qing,
    qing_gradient,
    Dict(
        :name => "qing",
        :description => "Qing Function. Properties based on Jamil & Yang (2013). Multiple global minima due to sign choices.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 - i)^2.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); sqrt.(1:n) end,
        :min_value => (n::Int) -> 0.0,
        :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Qing (2006)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-500.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(500.0, n) end,
    )
)
