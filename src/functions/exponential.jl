# src/functions/exponential.jl
# Purpose: Implementation of the Exponential test function.
# Context: Scalable, non-separable, from Ramanujan et al. (2007).
# Global minimum: f(x*)=-1 at x*=zeros(n).
# Bounds: -1 ≤ x_i ≤ 1.
# Last modified: September 26, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export EXPONENTIAL_FUNCTION, exponential, exponential_gradient

function exponential(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)  # Edge-Case-Handling
    any(isinf.(x)) && return T(Inf)
    
    g = sum(abs2, x)
    -exp(-T(0.5) * g)
end

function exponential_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Input vector must have at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)  # Edge-Case
    any(isinf.(x)) && return fill(T(Inf), n)
    
    g = sum(abs2, x)
    exp_g = exp(-T(0.5) * g)
    grad = x .* exp_g
    grad
end

const EXPONENTIAL_FUNCTION = TestFunction(
    exponential,
    exponential_gradient,
    Dict(
        :name => "exponential",
        :description => "The Exponential test function, a scalable, non-separable function with a unique global minimum at the origin. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = -\exp\left( -\frac{1}{2} \sum_{i=1}^n x_i^2 \right). """,
        :start => (n::Int) -> (n < 1 && throw(ArgumentError("Dimension n must be at least 1")); ones(Float64, n)),
        :min_position => (n::Int) -> (n < 1 && throw(ArgumentError("Dimension n must be at least 1")); zeros(Float64, n)),
        :min_value => (n::Int) -> -1.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "scalable", "unimodal"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Ramanujan et al. (2007)",
        :lb => (n::Int) -> (n < 1 && throw(ArgumentError("Dimension n must be at least 1")); -ones(Float64, n)),
        :ub => (n::Int) -> (n < 1 && throw(ArgumentError("Dimension n must be at least 1")); ones(Float64, n)),
    )
)
