# src/functions/griewank.jl
# Purpose: Implements the Griewank test function – classic deceptive multimodal benchmark
# Global minimum: f(x*) = 0 at x* = [0, ..., 0]
# Bounds: -600 ≤ x_i ≤ 600
# Last modified: 29 November 2025

export GRIEWANK_FUNCTION, griewank, griewank_gradient

function griewank(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    n = length(x)
    n ≥ 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))

    if T <: BigFloat
        setprecision(256)
    end

    sum_term = sum(x[i]^2 / 4000 for i in 1:n)
    prod_term = prod(cos(x[i] / sqrt(i)) for i in 1:n)
    sum_term - prod_term + 1
end

function griewank_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))

    n = length(x)
    n ≥ 1 || throw(ArgumentError("Griewank requires at least 1 dimension"))

    if T <: BigFloat
        setprecision(256)
    end

    grad = zeros(T, n)
    @inbounds for i in 1:n
        # Sum term derivative
        sum_part = 2 * x[i] / 4000

        # Product term derivative
        prod_other = prod(j -> j == i ? 1.0 : cos(x[j] / sqrt(j)), 1:n)
        sin_part = sin(x[i] / sqrt(i)) / sqrt(i)
        prod_part = prod_other * sin_part

        grad[i] = sum_part + prod_part
    end
    grad
end

const GRIEWANK_FUNCTION = TestFunction(
    griewank,
    griewank_gradient,
    Dict{Symbol, Any}(
        :name         => "griewank",
        :description  => "Griewank function – one of the most deceptive multimodal benchmarks in global optimization. " *
                         "The oscillating product term creates countless local minima that become increasingly misleading " *
                         "with higher dimensions. Gradient-based methods are systematically trapped far from the global minimum.",
        :math         => raw"f(\mathbf{x}) = \sum_{i=1}^n \frac{x_i^2}{4000} - \prod_{i=1}^n \cos\!\left(\frac{x_i}{\sqrt{i}}\right) + 1",
        :start        => (n::Int) -> fill(300.0, n),           # weit weg vom Minimum – RULE_START_AWAY_FROM_MIN
        :min_position => (n::Int) -> zeros(n),
        :min_value    => (n::Int) -> 0.0,
        :properties   => ["multimodal", "non-convex", "non-separable", "differentiable",
                           "scalable", "bounded", "continuous", "deceptive"],
        :default_n    => 10,
        :lb           => (n::Int) -> fill(-600.0, n),
        :ub           => (n::Int) -> fill(600.0, n),
        :source       => "Griewank (1981); " *
                         "Molga & Smutnicki (2005, p. 19); " *
                         "Jamil & Yang (2013, p. 57); " *
                         "Lehman & Stanley (2011, arXiv:1106.2128) – classic deceptive benchmark; " *
                         "Locatelli & Schoen (2013) – deception increases with dimension"
    )
)