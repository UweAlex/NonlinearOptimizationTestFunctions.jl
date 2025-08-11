# src/functions/dejongf4.jl
# Purpose: Implements the De Jong F4 (Quartic with noise) test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: 11 August 2025

export DEJONGF4_FUNCTION, dejongf4, dejongf4_gradient

using LinearAlgebra
using ForwardDiff
using Random

"""
    dejongf4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the De Jong F4 (Quartic with noise) function value at point `x`. Scalable to any dimension.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
"""
function dejongf4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    n = length(x)
    s = zero(T)
    @inbounds for i in 1:n
        s += i * x[i]^4
    end
    # Additive Noise-Term: Uniform[0,1)
    return s + rand(T)
end

"""
    dejongf4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}

Computes the gradient of the De Jong F4 function (deterministic part only). Returns a vector of length n.
"""
function dejongf4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), length(x))
    any(isinf.(x)) && return fill(T(Inf), length(x))
    n = length(x)
    g = similar(x)
    @inbounds for i in 1:n
        g[i] = 4 * i * x[i]^3
    end
    return g
end

const _DEJONGF4_NAME = "dejongf4"

const DEJONGF4_FUNCTION = begin
    meta = Dict{Symbol, Any}()

    meta[:name] = _DEJONGF4_NAME

    # Startpunkt: Standard für De Jong Funktionen
    meta[:start] = (n::Int) -> begin
        n >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
        zeros(n)
    end

    # Minimum (deterministischer Teil): x = 0, Wert = 0.0 + Uniform[0,1)
    meta[:min_position] = (n::Int) -> begin
        n >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
        zeros(n)
    end
    meta[:min_value] = 0.0  # Deterministischer Teil

    meta[:properties] = [
        "unimodal", "convex", "separable", "partially differentiable",
        "scalable", "continuous", "bounded", "has_noise"
    ]

    # Literaturgetreue Grenzen
    meta[:lb] = (n::Int) -> begin
        n >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
        fill(-1.28, n)
    end
    meta[:ub] = (n::Int) -> begin
        n >= 1 || throw(ArgumentError("De Jong F4 requires at least 1 dimension"))
        fill(1.28, n)
    end

    meta[:in_molga_smutnicki_2005] = true

    meta[:description] = "De Jong F4 (Quartic) with additive Uniform[0,1) noise per evaluation. " *
                        "The minimum value is 0.0 for the deterministic part, plus noise in [0,1). " *
                        "Noise is independent of x, so the analytical gradient is the same as for the pure quartic part."

    meta[:math] = raw"f(x) = \sum_{i=1}^n i\,x_i^4 \;+\; \mathrm{Uniform}(0,1)"

    TestFunction(dejongf4, dejongf4_gradient, meta)
end