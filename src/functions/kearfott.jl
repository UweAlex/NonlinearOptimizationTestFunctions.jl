# src/functions/kearfott.jl
# Purpose: Implements the Kearfott test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: August 27, 2025

export KEARFOTT_FUNCTION, kearfott, kearfott_gradient

using LinearAlgebra
using ForwardDiff

"""
    kearfott(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Kearfott function value at point `x`. Requires exactly 2 dimensions.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.

The function is defined as `(x₁² + x₂² - 2)² + (x₁² + x₂² - 0.5)²`, as specified in Jamil & Yang (2013). The global minima occur where x₁² + x₂² = 1.25, e.g., at (0.7905694150420949, -0.7905694150420949) and (-0.7905694150420949, 0.7905694150420949), with f(x*) = 1.125. 

**Important**: Jamil & Yang (2013) incorrectly lists the minima at (0.70710678, -0.70710678) and (-0.70710678, 0.70710678) with f(x*) = 0. These yield f = 1.25, not 0, indicating errors in the literature values for both the minima and the minimum value. The true global minimum is 1.125, achieved where x₁² + x₂² = 1.25.
"""
function kearfott(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Kearfott requires exactly 2 dimensions"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    x1, x2 = x
    norm_sq = x1^2 + x2^2
    (norm_sq - 2)^2 + (norm_sq - 0.5)^2
end

"""
    kearfott_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Kearfott function. Returns a vector of length 2.
"""
function kearfott_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Kearfott requires exactly 2 dimensions"))
    length(x) == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    x1, x2 = x
    norm_sq = x1^2 + x2^2
    grad1 = 4 * x1 * (norm_sq - 2) + 4 * x1 * (norm_sq - 0.5)
    grad2 = 4 * x2 * (norm_sq - 2) + 4 * x2 * (norm_sq - 0.5)
    [grad1, grad2]
end

const KEARFOTT_FUNCTION = TestFunction(
    kearfott,
    kearfott_gradient,
    Dict(
        :name => "kearfott",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [0.7905694150420949, -0.7905694150420949],
        :min_value => () -> 1.125,
        :properties => Set(["multimodal", "continuous", "differentiable", "non-separable", "bounded", "non-convex"]),
        :lb => () -> [-3.0, -3.0],
        :ub => () -> [4.0, 4.0],
        :in_molga_smutnicki_2005 => false,
        :description => "Kearfott function: Multimodal, continuous, differentiable, non-separable, bounded, non-convex. Global minima where x₁² + x₂² = 1.25, e.g., at (0.7905694150420949, -0.7905694150420949) and (-0.7905694150420949, 0.7905694150420949), f* = 1.125. Note: Jamil & Yang (2013) incorrectly lists minima at (0.70710678, -0.70710678) and (-0.70710678, 0.70710678) with f* = 0; those yield f = 1.25.",
        :math => "(x_1^2 + x_2^2 - 2)^2 + (x_1^2 + x_2^2 - 0.5)^2"
    )
)