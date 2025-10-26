# src/functions/sumofpowers.jl
# Purpose: Implements the Sum of Different Powers test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions.
# Last modified: October 26, 2025

export SUMOFPOWERS_FUNCTION, sumofpowers, sumofpowers_gradient

using LinearAlgebra
using ForwardDiff

# Computes the Sum of Different Powers function value at point `x`. Scalable to any n >= 1.
#
# Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
#
# The Sum of Different Powers function is defined as:
# f(x) = ∑_{i=1}^n |x_i|^{i+1}
#
# Reference: Jamil & Yang (2013, p. 32) [f_{145}]
function sumofpowers(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum = zero(T)
    @inbounds for i in 1:n  # SHOULD: @inbounds
        sum += abs(x[i])^(i + 1)
    end
    sum
end #function

# Computes the gradient of the Sum of Different Powers function. Returns a vector of length n.
#
# Throws `ArgumentError` if the input vector is empty or n < 1.
# Returns NaN-vector for NaN-inputs and Inf-vector for Inf-inputs.
function sumofpowers_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        grad[i] = (i + 1) * abs(x[i])^i * sign(x[i])  # [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end #function

const SUMOFPOWERS_FUNCTION = TestFunction(
    sumofpowers,
    sumofpowers_gradient,
    Dict(
        :name => "sumofpowers",  # [RULE_NAME_CONSISTENCY]
        :description => "Sum of Different Powers function: A unimodal, convex, differentiable, separable, scalable function with global minimum at origin. Properties based on Jamil & Yang (2013, p. 32) [f_{145}]; originally from Bingham (1995).",  # [RULE_PROPERTIES_SOURCE] [RULE_SOURCE_FORMULA_CONSISTENCY]
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n |x_i|^{i+1}""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension")); fill(0.5, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n>1 [RULE_DEFAULT_N]
        :properties => ["bounded", "continuous", "convex", "differentiable", "separable", "scalable", "unimodal"],  # Vector; sorted; only VALID_PROPERTIES [RULE_PROPERTIES_SOURCE]
        :source => "Jamil & Yang (2013, p. 32)",  # [RULE_PROPERTIES_SOURCE] – direct source with page; exact formula match for f_{145}
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension")); fill(-1.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("sumofpowers requires at least 1 dimension")); fill(1.0, n) end,
    )
)

# Optional: Validierung beim Laden [RULE_NAME_CONSISTENCY]
@assert "sumofpowers" == basename(@__FILE__)[1:end-3] "sumofpowers: Dateiname mismatch!"