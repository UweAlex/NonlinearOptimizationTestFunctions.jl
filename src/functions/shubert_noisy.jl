# src/functions/shubert_noisy.jl
# Purpose: Implementation of the noisy Shubert test function.
# Global minimum: f(x*)= -186.7309 + [0,1); at x*= one of 18 global minima.
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: December 11, 2025.

export SHUBERT_NOISY_FUNCTION, shubert_noisy, shubert_noisy_gradient

function shubert_noisy(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual,BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_noisy requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    if T <: BigFloat
        setprecision(256)
    end

    # Deterministic base
    base = one(T)
    @inbounds for i in 1:n
        sum_inner = zero(T)
        @inbounds for j in 1:5
            sum_inner += T(j) * cos((T(j) + 1) * x[i] + T(j))
        end
        base *= sum_inner
    end

    # Additive uniform [0,1) noise; zero for Dual/BigFloat
    noise = (T <: Real) ? T(rand()) : zero(T)

    base + noise
end

function shubert_noisy_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual,BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_noisy requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    if T <: BigFloat
        setprecision(256)
    end

    grad = zeros(T, n)
    # Deterministic base gradient (noise derivative zero)
    inners = zeros(T, n)
    @inbounds for i in 1:n
        sum_inner = zero(T)
        @inbounds for j in 1:5
            sum_inner += T(j) * cos((T(j) + 1) * x[i] + T(j))
        end
        inners[i] = sum_inner
    end

    base = prod(inners)

    @inbounds for i in 1:n
        grad_i = base / inners[i] # Product rule factor
        sum_deriv = zero(T)
        @inbounds for j in 1:5
            sum_deriv -= T(j) * (T(j) + 1) * sin((T(j) + 1) * x[i] + T(j))
        end
        grad[i] = grad_i * sum_deriv
    end
    grad
end

const SHUBERT_NOISY_FUNCTION = TestFunction(
    shubert_noisy,
    shubert_noisy_gradient,
    Dict{Symbol,Any}(
        :name => "shubert_noisy",
        :description => "Noisy variant of Shubert function; additive uniform [0,1) noise. Properties based on Jamil & Yang (2013, p. 55) for base; noise adapted for stochastic benchmark. Gradient is deterministic (noise constant per call). Multiple global minima (18 in 2D).",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^D \sum_{j=1}^5 j \cos((j + 1) x_i + j) + \varepsilon, \quad \varepsilon \sim U[0,1).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-7.083506405745021, -7.708313737307907],
        :min_value => () -> -186.7309088310239,
        :properties => ["continuous", "non-separable", "multimodal", "has_noise"], # 'differentiable' entfernt
        :source => "Jamil & Yang (2013, p. 55); noise adapted",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)