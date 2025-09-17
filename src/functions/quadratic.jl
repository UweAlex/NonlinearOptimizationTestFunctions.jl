# src/functions/quadratic.jl
# Purpose: Implements a generic quadratic test function with optional parameters A, b, c, which are set on first call and encapsulated for subsequent calls.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 13 September 2025

export QUADRATIC_FUNCTION, quadratic, quadratic_gradient

using LinearAlgebra
using ForwardDiff

"""
    generate_positive_definite_matrix(n::Int, condition_number=10.0)
Generates a random positive definite matrix of size n x n with specified condition number.
"""
function generate_positive_definite_matrix(n::Int, condition_number=10.0)
    n >= 1 || throw(ArgumentError("Dimension must be at least 1"))
    A_rand = randn(n, n)
    Q, _ = qr(A_rand)
    Q = Matrix(Q)
    λ_min = 1.0
    λ_max = condition_number
    λ = λ_min .+ (λ_max - λ_min) * rand(n)
    D = Diagonal(λ)
    A = Q' * D * Q
    return Symmetric(A)
end

# Encapsulated parameters
const A_fixed = Ref{Any}(nothing)
const b_fixed = Ref{Any}(nothing)
const c_fixed = Ref{Any}(nothing)
const is_initialized = Ref(false)
const current_dim = Ref{Int}(0)  # Track current dimension

"""
    quadratic(x::AbstractVector{T}, A=nothing, b=nothing, c=nothing) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the quadratic function value at point `x`. Parameters A, b, c are set on first call or overridden if provided.
"""
function quadratic(x::AbstractVector{T}, A=nothing, b=nothing, c=nothing) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n >= 1 || throw(ArgumentError("Dimension must be at least 1"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if !is_initialized[] || !isnothing(A) || !isnothing(b) || !isnothing(c) || current_dim[] != n
        A_fixed[] = isnothing(A) ? generate_positive_definite_matrix(n, 10.0) : copy(A)
        b_fixed[] = isnothing(b) ? zeros(T, n) : copy(b)
        c_fixed[] = isnothing(c) ? T(0.0) : T(c)
        eigvals_A = eigvals(A_fixed[])
        all(eigvals_A .> 0) || throw(ArgumentError("Matrix A must be positive definite"))
        length(b_fixed[]) == n || throw(ArgumentError("Vector b must have length n"))
        is_initialized[] = true
        current_dim[] = n
    end

    return dot(x, A_fixed[]*x) + dot(b_fixed[], x) + c_fixed[]
end

"""
    quadratic_gradient(x::AbstractVector{T}, A=nothing, b=nothing, c=nothing) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the quadratic function. Parameters A, b, c are set on first call or overridden if provided.
"""
function quadratic_gradient(x::AbstractVector{T}, A=nothing, b=nothing, c=nothing) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n >= 1 || throw(ArgumentError("Dimension must be at least 1"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if !is_initialized[] || !isnothing(A) || !isnothing(b) || !isnothing(c) || current_dim[] != n
        A_fixed[] = isnothing(A) ? generate_positive_definite_matrix(n, 10.0) : copy(A)
        b_fixed[] = isnothing(b) ? zeros(T, n) : copy(b)
        c_fixed[] = isnothing(c) ? T(0.0) : T(c)  # Added to ensure c_fixed[] is initialized
        eigvals_A = eigvals(A_fixed[])
        all(eigvals_A .> 0) || throw(ArgumentError("Matrix A must be positive definite"))
        length(b_fixed[]) == n || throw(ArgumentError("Vector b must have length n"))
        is_initialized[] = true
        current_dim[] = n
    end

    return 2 * A_fixed[] * x + b_fixed[]
end

const QUADRATIC_FUNCTION = TestFunction(
    quadratic,
    quadratic_gradient,
    Dict(
        :name => "quadratic",
        :start => (dim::Int) -> begin
            dim >= 1 || throw(ArgumentError("Dimension must be at least 1"))
            fill(0.0, dim)
        end,
        :min_position => (dim::Int) -> begin
            dim >= 1 || throw(ArgumentError("Dimension must be at least 1"))
            is_initialized[] ? -0.5 * (A_fixed[]\b_fixed[]) : fill(0.0, dim)
        end,
        :min_value => (dim::Int) -> begin
            dim >= 1 || throw(ArgumentError("Dimension must be at least 1"))
            is_initialized[] ? c_fixed[] - 0.25 * dot(b_fixed[], A_fixed[]\b_fixed[]) : 0.0
        end,
        :properties => Set(["unimodal", "convex", "non-separable", "differentiable", "scalable", "continuous"]),
        :lb => (dim::Int) -> begin
            dim >= 1 || throw(ArgumentError("Dimension must be at least 1"))
            fill(-Inf, dim)
        end,
        :ub => (dim::Int) -> begin
            dim >= 1 || throw(ArgumentError("Dimension must be at least 1"))
            fill(Inf, dim)
        end,
        :description => "Generic quadratic function f(x) = x^T A x + b^T x + c with a positive definite matrix A, initialized on first call or with user-defined parameters, scalable for testing optimization algorithms on non-separable problems with varying condition numbers.",
        :math => "x^T A x + b^T x + c"
    )
)