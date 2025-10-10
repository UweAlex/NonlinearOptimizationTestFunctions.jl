# src/functions/salomon.jl
# Purpose: Implementation of the Salomon test function.
# Global minimum: f(x*)=0.0 at x*=(0,...,0) (n-dependent).
# Bounds: -100 ≤ x_i ≤ 100.

export SALOMON_FUNCTION, salomon, salomon_gradient

function salomon(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    r = sqrt(sum(x -> x^2, x))  # sqrt(sum x_i^2)
    one(T) - cos(2 * pi * r) + 0.1 * r
end

function salomon_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    r2 = zero(T)
    @inbounds for xi in x
        r2 += xi^2
    end
    if iszero(r2)
        return zeros(T, n)
    end
    r = sqrt(r2)
    dfdr = 2 * pi * sin(2 * pi * r) + 0.1
    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = dfdr * (x[i] / r)
    end
    grad
end

const SALOMON_FUNCTION = TestFunction(
    salomon,
    salomon_gradient,
    Dict(
        :name => "salomon",
        :description => "The Salomon function. Properties based on Jamil & Yang (2013, p. 27); originally from Salomon (1996).",
        :math => raw"""f(\mathbf{x}) = 1 - \cos\left(2\pi \sqrt{\sum_{i=1}^D x_i^2}\right) + 0.1 \sqrt{\sum_{i=1}^D x_i^2}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Constant value (ignores n)
        :default_n => 2,  # Smallest n >1 for general scalability
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 27)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)