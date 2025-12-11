# src/functions/bohachevsky1.jl
# Purpose: Implementation of the Bohachevsky 1 test function.
# Global minimum: f(x*)=0 at x*=zeros(n) for any n ≥ 2.
# Bounds: -100 ≤ x_i ≤ 100.

export BOHACHEVSKY1_FUNCTION, bohachevsky1, bohachevsky1_gradient

function bohachevsky1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    s = zero(T)
    @inbounds for i in 1:n-1
        s += x[i]^2 + 2*x[i+1]^2 - 0.3*cos(3π*x[i]) - 0.4*cos(4π*x[i+1]) + 0.7
    end
    s
end

function bohachevsky1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    grad = zeros(T, n)
    @inbounds for i in 1:n-1
        grad[i]   += 2*x[i]   + 0.3*3π*sin(3π*x[i])
        grad[i+1] += 4*x[i+1] + 0.4*4π*sin(4π*x[i+1])
    end
    grad
end

const BOHACHEVSKY1_FUNCTION = TestFunction(
    bohachevsky1,
    bohachevsky1_gradient,
    Dict{Symbol, Any}(
        :name => "bohachevsky1",
        :description => "Bohachevsky 1 function. Scalable, separable, multimodal test function with global minimum 0 at the origin. Properties based on Jamil & Yang (2013, p. 10).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[ x_i^2 + 2 x_{i+1}^2 - 0.3 \cos(3 \pi x_i) - 0.4 \cos(4 \pi x_{i+1}) + 0.7 \right].""",
        :start => (n::Int) -> (
            n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"));
            fill(1.0, n)  # entfernt vom Minimum → f(start) >> 0 (erfüllt RULE_START_AWAY_FROM_MIN)
        ),
        :min_position => (n::Int) -> (
            n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"));
            zeros(n)
        ),
        :min_value => (n::Int) -> 0.0,        # konstant, aber als Funktion (RULE_META_CONSISTENCY)
        :default_n => 2,                      # kleinste erlaubte Dimension (RULE_DEFAULT_N)
        :properties => [
            "bounded", "continuous", "differentiable",
            "multimodal", "non-convex", "scalable", "separable"
        ],
        :source => "Jamil & Yang (2013, p. 10)",
        :lb => (n::Int) -> (
            n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"));
            fill(-100.0, n)
        ),
        :ub => (n::Int) -> (
            n < 2 && throw(ArgumentError("bohachevsky1 requires at least 2 dimensions"));
            fill(100.0, n)
        ),
    )
)

