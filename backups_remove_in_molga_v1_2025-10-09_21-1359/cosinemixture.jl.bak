# src/functions/cosinemixture.jl
# Purpose: Defines the Cosine Mixture test function, its gradient, and metadata.
# Context: Part of NonlinearOptimizationTestFunctions, providing a benchmark for optimization algorithms.
# Last modified: 20 September 2025

# Cosine Mixture Function (continuous, differentiable, separable, scalable, multimodal, non-convex)
# Formula: f(x) = -0.1 * sum_{i=1}^n cos(5 π x_i) - sum_{i=1}^n x_i^2
# Domain: x ∈ [-1, 1]^n
# Global minimum: -0.1 * n at (0, ..., 0)
# Properties: Based on Jamil & Yang (2013): f38, Ali et al. (2005)

function cosinemixture(x::AbstractVector{T}) where {T <: Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Cosine Mixture requires at least 1 dimension"))
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    sum_cos = sum(cos(5 * pi * xi) for xi in x)
    sum_sq = sum(xi^2 for xi in x)
    return -0.1 * sum_cos - sum_sq
end

function cosinemixture_gradient(x::AbstractVector{T}) where {T <: Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n < 1 && throw(ArgumentError("Cosine Mixture requires at least 1 dimension"))
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    grad = similar(x)
    for i in 1:n
        grad[i] = 0.5 * pi * sin(5 * pi * x[i]) - 2 * x[i]
    end
    return grad
end

const COSINEMIXTURE_META = Dict(
    :name => "cosinemixture",
    :start => (n::Int) -> fill(0.5, n),
    :min_position => (n::Int) -> fill(0.0, n),
    :min_value => (n::Int) -> -0.1 * n,
    :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal", "non-convex", "bounded"],
        :default_n => 2,
    :lb => (n::Int) -> fill(-1.0, n),
    :ub => (n::Int) -> fill(1.0, n),
    :description => "Cosine Mixture Function: A multimodal, separable benchmark with global minimum -0.1*n at origin.",
    :math => raw"f(\mathbf{x}) = -0.1 \sum_{i=1}^n \cos(5 \pi x_i) - \sum_{i=1}^n x_i^2"
)

const COSINEMIXTURE_FUNCTION = TestFunction(cosinemixture, cosinemixture_gradient, COSINEMIXTURE_META)

export COSINEMIXTURE_FUNCTION, cosinemixture, cosinemixture_gradient
