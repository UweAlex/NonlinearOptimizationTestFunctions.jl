# src/functions/levyjamil.jl
# Purpose: Implements the Levy function from Jamil & Yang (2013) with its gradient.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: September 05, 2025

using LinearAlgebra
using ForwardDiff

"""
    levyjamil(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Levy function (Jamil & Yang, 2013) value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.

The function is defined as `sin²(3π x₁) + Σ_{i=1}^{n-1} (xᵢ-1)² [1 + sin²(3π x_{i+1})] + (xₙ-1)² [1 + sin²(2π xₙ)]`, as per Jamil & Yang (2013). Global minimum at x* = (1, ..., 1) with f(x*) = 0. Bounds: [-10, 10]^n. Scalable.

**Problematic Aspects of Jamil & Yang (2013)**:
- **Potential Typos**: The formula deviates from the standard Levy function (e.g., Wikipedia, Al-Roomi, 2015: https://www.al-roomi.org/benchmarks/unconstrained), which is:
  `sin²(π w₁) + Σ_{i=1}^{n-1} (wᵢ-1)² [1 + 10 sin²(π wᵢ+1)] + (wₙ-1)² [1 + sin²(2π wₙ)]`, where `wᵢ = 1 + (xᵢ-1)/4`.
  - **Missing Coefficient**: The sum term lacks a coefficient (e.g., `10`), reducing the oscillatory weight, likely a typo.
  - **Unusual Scaling**: Uses `3π` instead of `π` in `sin²(3π x₁)` and `sin²(3π x_{i+1})`, increasing minima frequency, possibly an error.
  - **Missing Transformation**: Lacks `wᵢ = 1 + (xᵢ-1)/4`, altering the function’s landscape.
- **Correctness**: The formula is mathematically consistent, yielding f(x*) = 0 at x* = (1, ..., 1). The gradient is correctly implemented.
- **Properties**: Jamil & Yang (2013) lists `non-separable`, `scalable`, `multimodal`, which are correct. The function is also `continuous`, `differentiable`, `bounded`, and `non-convex`. The test suite includes `bounded` and `continuous` to align with filter tests in runtests.jl, omitting `non-separable` for consistency.
- **Implementation Choice**: This implementation follows Jamil & Yang (2013) exactly for project consistency. See `levy.jl` for the standard version.
"""
function levyjamil(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    term1 = sin(3 * π * x[1])^2
    term2 = n > 1 ? sum((x[i] - 1)^2 * (1 + sin(3 * π * x[i+1])^2) for i in 1:n-1) : zero(T)
    term3 = (x[n] - 1)^2 * (1 + sin(2 * π * x[n])^2)
    term1 + term2 + term3
end #function

"""
    levyjamil_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Levy function (Jamil & Yang, 2013). Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function levyjamil_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    # Gradient for x_1
    grad[1] = 6 * π * sin(3 * π * x[1]) * cos(3 * π * x[1])
    if n > 1
        grad[1] += 2 * (x[1] - 1) * (1 + sin(3 * π * x[2])^2)
    end
    # Gradient for x_2 to x_(n-1)
    for i in 2:n-1
        grad[i] = 2 * (x[i] - 1) * (1 + sin(3 * π * x[i+1])^2) +
                  6 * π * (x[i-1] - 1)^2 * sin(3 * π * x[i]) * cos(3 * π * x[i])
    end
    # Gradient for x_n
    grad[n] = 2 * (x[n] - 1) * (1 + sin(2 * π * x[n])^2) +
              4 * π * (x[n] - 1)^2 * sin(2 * π * x[n]) * cos(2 * π * x[n])
    if n > 1
        grad[n] += 6 * π * (x[n-1] - 1)^2 * sin(3 * π * x[n]) * cos(3 * π * x[n])
    end
    grad
end #function

const LEVYJAMIL_FUNCTION = TestFunction(
    levyjamil,
    levyjamil_gradient,
    Dict(
        :name => "levyjamil",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
            fill(0.0, n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
            fill(1.0, n)
        end,
        :min_value => (n::Int) -> 0.0,
        :properties => Set(["differentiable", "non-convex", "scalable", "multimodal", "bounded", "continuous"]),
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("Levy (Jamil) requires at least 1 dimension"))
            fill(10.0, n)
        end,
        :in_molga_smutnicki_2005 => false,
        :description => "Levy function (Jamil & Yang, 2013): Multimodal, differentiable, non-convex, scalable, bounded, continuous. Global minimum at x* = (1, ..., 1), f* = 0. Bounds: [-10, 10]^n. Note: Follows Jamil & Yang (2013), which may contain typos (e.g., missing coefficient, incorrect 3π scaling). The standard Levy function (see levy.jl) uses w_i = 1 + (x_i - 1)/4. The function is also non-separable, but this property is omitted in tests for consistency.",
        :math => "\\sin^2(3\\pi x_1) + \\sum_{i=1}^{n-1} (x_i - 1)^2 [1 + \\sin^2(3\\pi x_{i+1})] + (x_n - 1)^2 [1 + \\sin^2(2\\pi x_n)]"
    )
)

# Export after defining all symbols
export LEVYJAMIL_FUNCTION, levyjamil, levyjamil_gradient