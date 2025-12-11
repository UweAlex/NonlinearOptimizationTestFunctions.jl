# src/functions/ackley.jl
# Purpose: Ackley function – highly deceptive multimodal benchmark
# Global minimum: f(0) = 0
# Last update: 29 November 2025

export ACKLEY_FUNCTION, ackley, ackley_gradient

function ackley(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    n = length(x)
    n ≥ 1 || throw(ArgumentError("Ackley requires at least 1 dimension"))

    if T <: BigFloat
        setprecision(256)
    end

    a, b, c = 20.0, 0.2, 2π
    sum_sq = sum(abs2, x) / n
    sum_cos = sum(cospi(2 * xi) for xi in x) / n  # cos(2πx) = cospi(2x)

    -a * exp(-b * sqrt(sum_sq)) - exp(sum_cos) + a + exp(1)
end

function ackley_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))

    n = length(x)
    n ≥ 1 || throw(ArgumentError("Ackley requires at least 1 dimension"))

    if T <: BigFloat
        setprecision(256)
    end

    a, b, c = 20.0, 0.2, 2π
    sum_sq = sum(abs2, x)

    if iszero(sum_sq)
        return zeros(T, n)
    end

    sqrt_mean = sqrt(sum_sq / n)
    term1 = (a * b * exp(-b * sqrt_mean) / sqrt_mean) / n
    term2 = exp(sum(cospi(2 * xi) for xi in x) / n) * c / n

    grad = similar(x, T)
    @inbounds for i in 1:n
        grad[i] = term1 * x[i] + term2 * sinpi(2 * x[i])
    end
    grad
end

const ACKLEY_FUNCTION = TestFunction(
    ackley,
    ackley_gradient,
    Dict{Symbol, Any}(
        :name         => "ackley",
        :description  => "Ackley function – one of the most famous deceptive multimodal benchmarks. " *
                         "Nearly flat outer region with a deep central hole and countless cosine-induced local minima. " *
                         "Systematically misleads gradient-based and local optimizers away from the global minimum at zero.",
        :math         => raw"f(\mathbf{x}) = -20\exp\!\left(-0.2\sqrt{\frac{1}{n}\sum x_i^2}\right) - \exp\!\left(\frac{1}{n}\sum\cos(2\pi x_i)\right) + 20 + e",
        :start        => (n::Int) -> fill(16.0, n),           # weit weg vom Minimum!
        :min_position => (n::Int) -> zeros(n),
        :min_value    => (n::Int) -> 0.0,
        :properties   => ["multimodal", "non-convex", "non-separable", "differentiable",
                           "scalable", "bounded", "continuous", "deceptive"],
        :default_n    => 10,
        :lb           => (n::Int; bounds="default") -> bounds == "alternative" ? fill(-5.0, n) : fill(-32.768, n),
        :ub           => (n::Int; bounds="default") -> bounds == "alternative" ? fill(5.0, n) : fill(32.768, n),
        :source       => "Ackley (1987); " *
                         "Molga & Smutnicki (2005); " *
                         "Jamil & Yang (2013); " *
                         "Lehman & Stanley (2011, arXiv:1106.2128) – classic deceptive function"
    )
)