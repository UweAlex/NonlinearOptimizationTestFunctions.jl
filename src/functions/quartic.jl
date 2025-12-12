# src/functions/quartic.jl
# Purpose: Implementation of the Quartic Function test function.
# Context: Scalable (n >= 1), with additive uniform noise [0,1). Unimodal deterministic part.
# Global minimum: f(x*)=0 at x*=zeros(n) (ignoring noise).
# Bounds: -1.28 ≤ x_i ≤ 1.28.
# Start point: fill(0.8, n) → NICHT das Minimum!
# Last modified: November 13, 2025.
export QUARTIC_FUNCTION, quartic, quartic_gradient

function quartic(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    sum_f = zero(T)
    @inbounds for i in 1:n
        sum_f += i * x[i]^4
    end
    sum_f + rand()  # Uniform noise in [0,1)
end

function quartic_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    grad = zeros(T, n)
    @inbounds for i in 1:n
        grad[i] = 4 * i * x[i]^3
    end
    grad  # Noise is non-differentiable → gradient of deterministic part only
end

const QUARTIC_FUNCTION = TestFunction(
    quartic,
    quartic_gradient,
    Dict{Symbol,Any}(
        :name => "quartic",
        :description => "Quartic Function with additive uniform noise from [0,1). The deterministic part is strictly convex, but the overall function is non-differentiable due to random noise. Gradient implementation returns derivative of deterministic component only. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n} i x_i^4 + \mathcal{U}[0, 1).""",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("quartic requires n >= 1"))
            fill(0.8, n)  # GEÄNDERT: NICHT zeros(n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("quartic requires n >= 1"))
            zeros(n)
        end,
        :min_value => (n::Int) -> 0.0,  # Ignoring noise
        :default_n => 2,
        :properties => ["bounded", "continuous", "has_noise", "scalable", "separable", "unimodal"],  # FIXED: Removed "differentiable" (incompatible with "has_noise"), alphabetically sorted
        :source => "Jamil & Yang (2013)",
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("quartic requires n >= 1"))
            fill(-1.28, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("quartic requires n >= 1"))
            fill(1.28, n)
        end,
    )
)